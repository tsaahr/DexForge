class WildBattle < ApplicationRecord
  belongs_to :user_pokemon
  belongs_to :wild_pokemon
  belongs_to :winner, polymorphic: true, optional: true

  def ongoing?
    user_pokemon.current_hp > 0 && wild_pokemon.current_hp > 0
  end

  def finished?
    !ongoing?
  end

  def execute_turn!
    return unless ongoing?

    attacker, defender =
      current_turn == "user" ? [user_pokemon, wild_pokemon] : [wild_pokemon, user_pokemon]

    move = choose_move(attacker)
    damage = calculate_damage(attacker, defender, move)
    defender.current_hp -= damage
    defender.current_hp = 0 if defender.current_hp < 0
    defender.save!

    self.battle_log ||= ""
    self.battle_log += "#{attacker.name_or_nickname} used #{move[:name]} and dealt #{damage} damage!\n"

    if defender.current_hp <= 0
      self.winner = attacker
      self.battle_log += "#{attacker.name_or_nickname} won the battle!\n"
    else
      self.current_turn = current_turn == "user" ? "wild" : "user"
    end

    save!
  end

  def choose_move(pokemon)
    pokemon.moves.sample
  end

  def calculate_damage(attacker, defender, move)
    level_factor = (attacker.level / 5.0).clamp(1, 10)
    ((move[:power] || 30) * level_factor).round
  end
end
