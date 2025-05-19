class Battle < ApplicationRecord
  belongs_to :user_pokemon_1, class_name: "UserPokemon"
  belongs_to :user_pokemon_2, class_name: "UserPokemon"
  belongs_to :winner, class_name: 'UserPokemon', optional: true
  has_many :battle_logs, as: :battleable, dependent: :destroy
  has_many :battle_turns, as: :battleable, dependent: :destroy

  enum status: {
    pending: 'pending',
    ongoing: 'ongoing',
    finished: 'finished'
  }

  after_create :start_battle!

  def start_battle!
    update!(
      status: :ongoing,
      turn: 1,
      stat_stages: default_stat_stages
    )
    initialize_current_hp(user_pokemon_1)
    initialize_current_hp(user_pokemon_2)
    save_both
  end

  def execute_turn!(attacker_move:, defender_move:)
    BattleEngine.new(self, attacker_move: attacker_move, defender_move: defender_move).execute_turn!
  end

  def stat_stage(pokemon, stat)
    stages = stat_stages[pokemon.id.to_s] || base_stage_hash
    stages[stat] || 0
  end

  def base_stage_hash
    {
      "attack" => 0,
      "defense" => 0,
      "speed" => 0,
      "sp_attack" => 0,
      "sp_defense" => 0,
      "accuracy" => 0,
      "evasion" => 0
    }
  end

  def default_stat_stages
    {
      user_pokemon_1_id.to_s => base_stage_hash.dup,
      user_pokemon_2_id.to_s => base_stage_hash.dup
    }
  end

  def battle_log
    battle_turns.order(:turn_number).map do |turn|
      attacker_name = turn.attacker.pokemon.name
      defender_name = turn.defender.pokemon.name
      damage = turn.damage
      defender_hp = turn.defender.current_hp

      "Turn #{turn.turn_number}: #{attacker_name} attacked #{defender_name}, causing #{damage} damage. #{defender_name} has #{defender_hp} HP remaining."
    end.join("\n")
  end

  def reset_health!
    user_pokemon_1.update!(current_hp: user_pokemon_1.hp)
    user_pokemon_2.update!(current_hp: user_pokemon_2.hp)
    update!(status: :pending, turn: nil, winner: nil)
  end

  private

  def initialize_current_hp(user_pokemon)
    if user_pokemon.current_hp.nil?
      user_pokemon.current_hp = user_pokemon.hp
      user_pokemon.save!
    end
  end

  def save_both
    user_pokemon_1.save!
    user_pokemon_2.save!
  end
end
