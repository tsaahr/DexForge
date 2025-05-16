class Battle < ApplicationRecord
  belongs_to :user_pokemon_1, class_name: "UserPokemon"
  belongs_to :user_pokemon_2, class_name: "UserPokemon"
  belongs_to :winner, class_name: 'UserPokemon', optional: true


  has_many :battle_turns, dependent: :destroy

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
  
  def default_stat_stages
    {
      user_pokemon_1_id.to_s => base_stage_hash,
      user_pokemon_2_id.to_s => base_stage_hash
    }
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
  

  def execute_turn!(attacker_move:, defender_move:)
    return if finished?
  
    first_attacker, second_attacker = decide_turn_order
    first_move = first_attacker == user_pokemon_1 ? attacker_move : defender_move
    second_move = second_attacker == user_pokemon_1 ? attacker_move : defender_move
 
    if accuracy_check?(first_attacker, second_attacker, first_move)
      apply_stat_changes!(first_move, first_attacker, second_attacker)
      damage = calculate_damage(first_attacker, second_attacker)
    else
      damage = 0
    end
  
    second_attacker.current_hp -= damage
    second_attacker.current_hp = 0 if second_attacker.current_hp < 0
    second_attacker.save!
  
    battle_turns.create!(
      battle: self,
      attacker: first_attacker,
      defender: second_attacker,
      damage: damage,
      turn_number: turn
    )
  
    if battle_over?
      update!(status: :finished, winner: first_attacker)
      return true
    end
  
    if accuracy_check?(second_attacker, first_attacker, second_move)
      apply_stat_changes!(second_move, second_attacker, first_attacker)
      damage = calculate_damage(second_attacker, first_attacker)
    else
      damage = 0
    end
  
    first_attacker.current_hp -= damage
    first_attacker.current_hp = 0 if first_attacker.current_hp < 0
    first_attacker.save!
  
    battle_turns.create!(
      battle: self,
      attacker: second_attacker,
      defender: first_attacker,
      damage: damage,
      turn_number: turn
    )
  
    if battle_over?
      update!(status: :finished, winner: second_attacker)
    else
      increment!(:turn)
    end
  
    true
  end  

  def calculate_damage(attacker, defender)
    attack = apply_stage(attacker.attack, stat_stage(attacker, "attack"))
    defense = apply_stage(defender.defense, stat_stage(defender, "defense"))
  
    base_damage = attack - (defense / 2)
    base_damage.positive? ? base_damage : 1
  end
  
  def stat_stage(pokemon, stat)
    stages = stat_stages[pokemon.id.to_s] || base_stage_hash
    stages[stat] || 0
  end
  
  
  def apply_stat_changes!(move, attacker, defender)
    return if move.stat_changes.empty?
  
    move.stat_changes.each do |change|
      target = change_targets_self?(move) ? attacker : defender
      apply_stage_change!(target, change.stat_name, change.change)
    end
  end
  
  def apply_stage_change!(pokemon, stat, change_amount)
    key = pokemon.id.to_s
    self.stat_stages[key] ||= base_stage_hash
    self.stat_stages[key][stat] ||= 0
    self.stat_stages[key][stat] += change_amount
    self.stat_stages[key][stat] = self.stat_stages[key][stat].clamp(-6, 6)
    save!
  end
  
  def change_targets_self?(move)
    move.damage_class == "status"
  end
  

  def accuracy_check?(attacker, defender, move)
    acc_stage = stat_stage(attacker, "accuracy")
    eva_stage = stat_stage(defender, "evasion")
  
    final_accuracy = move.accuracy * (1 + acc_stage * 0.1 - eva_stage * 0.1)
    final_accuracy = final_accuracy.clamp(1, 100)
    rand(100) < final_accuracy
  end  
  

  def battle_over?
    user_pokemon_1.current_hp <= 0 || user_pokemon_2.current_hp <= 0
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
    end
  end

  def save_both
    user_pokemon_1.save!
    user_pokemon_2.save!
  end
end
