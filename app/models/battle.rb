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
      user_pokemon_1_id.to_s => base_stage_hash.dup,
      user_pokemon_2_id.to_s => base_stage_hash.dup
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
  

  def decide_turn_order(attacker_move:, defender_move:)
    speed_1 = user_pokemon_1.pokemon.stats.find { |s| s["stat"]["name"] == "speed" }["base_stat"]
    speed_2 = user_pokemon_2.pokemon.stats.find { |s| s["stat"]["name"] == "speed" }["base_stat"]
  
    if speed_1 > speed_2
      [user_pokemon_1, user_pokemon_2]
    elsif speed_2 > speed_1
      [user_pokemon_2, user_pokemon_1]
    else
      [user_pokemon_1, user_pokemon_2].shuffle
    end
  end

  def execute_turn!(attacker_move:, defender_move:)
    return if finished?
  
    first_attacker, second_attacker = decide_turn_order(
      attacker_move: attacker_move,
      defender_move: defender_move
    )

    first_attacker.reload
    second_attacker.reload
  
    first_move = first_attacker == user_pokemon_1 ? attacker_move : defender_move
    second_move = second_attacker == user_pokemon_1 ? attacker_move : defender_move  
 
    if accuracy_check?(first_attacker, second_attacker, first_move)
      apply_stat_changes!(first_move, first_attacker, second_attacker)
      damage = calculate_damage(first_attacker, second_attacker, first_move)
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
      damage = calculate_damage(second_attacker, first_attacker, second_move)
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

  def type_effectiveness_multiplier(move, defender)
    attack_type = move.type
    return 1.0 unless attack_type && defender.pokemon.types.any?
  
    defender.pokemon.types.reduce(1.0) do |total_multiplier, def_type|
      effectiveness = TypeEffectiveness.find_by(
        attacking_type: attack_type,
        defending_type: def_type
      )
      total_multiplier * (effectiveness&.multiplier || 1.0)
    end
  end

  def modified_stat(pokemon, base_stat, stat_symbol)
    stage = stat_stage(pokemon, stat_symbol.to_s)
    multiplier = case stage
                 when -6 then 2.0 / 8
                 when -5 then 2.0 / 7
                 when -4 then 2.0 / 6
                 when -3 then 2.0 / 5
                 when -2 then 2.0 / 4
                 when -1 then 2.0 / 3
                 when 0  then 1.0
                 when 1  then 3.0 / 2
                 when 2  then 4.0 / 2
                 when 3  then 5.0 / 2
                 when 4  then 6.0 / 2
                 when 5  then 7.0 / 2
                 when 6  then 8.0 / 2
                 else 1.0
                 end
    (base_stat * multiplier).round
  end
  
  

  def calculate_damage(attacker, defender, move)
    return 0 if move.nil? || move.power.nil? || move.power <= 0
  
    # Define os stats com base na classe de dano do movimento
    if move.physical?
      attack_stat  = modified_stat(attacker, attacker.attack, :attack)
      defense_stat = modified_stat(defender, defender.defense, :defense)
      puts "[Físico] Atk: #{attack_stat} | Def: #{defense_stat}"
    elsif move.special?
      attack_stat  = modified_stat(attacker, attacker.sp_attack, :sp_attack)
      defense_stat = modified_stat(defender, defender.sp_defense, :sp_defense)
      puts "[Especial] Sp.Atk: #{attack_stat} | Sp.Def: #{defense_stat}"
    else
      puts "[Status] Move não causa dano"
      return 0
    end
  
    # STAB (Same Type Attack Bonus)
    stab = attacker.pokemon.types.include?(move.move_type) ? 1.5 : 1.0
    puts "STAB: #{stab}"
  
    # Eficácia do tipo
    effectiveness = type_effectiveness_multiplier(move, defender)
    puts "Eficácia contra tipo: #{effectiveness}"
  
    # Fator aleatório (variação entre 0.85 e 1.0)
    random_factor = rand(0.85..1.0)
    puts "Fator aleatório: #{random_factor.round(2)}"
  
    # Nível do Pokémon atacante
    level = attacker.level # Default level 50, se não tiver sistema de level ainda
  
    # Fórmula oficial
    base_damage = (((((2 * level) / 5.0 + 2) * move.power * (attack_stat.to_f / defense_stat)) / 50.0) + 2)
    puts "Dano base: #{base_damage.round(2)}"
  
    # Dano final
    total_damage = (base_damage * stab * effectiveness * random_factor).floor
    puts "Dano final: #{total_damage}"
  
    total_damage
  end
  
  
  
  
  
  def stat_stage(pokemon, stat)
    stages = stat_stages[pokemon.id.to_s] || base_stage_hash
    stages[stat] || 0
  end
  
  
  def apply_stat_changes!(move, attacker, defender)
    return unless move.damage_class == "status"
  
    move.stat_changes.each do |change|
      target = change_targets_self?(move) ? attacker : defender
      stat = change["stat"]["name"]
      amount = change["change"]
  
      apply_stage_change!(target, stat, amount)
    end
  end
  
  
  
  
  def apply_stage_change!(pokemon, stat, change_amount)
    key = pokemon.id.to_s
    stat_str = stat.to_s
    self.stat_stages[key] ||= base_stage_hash
    self.stat_stages[key][stat_str] ||= 0
    self.stat_stages[key][stat_str] += change_amount
    self.stat_stages[key][stat_str] = self.stat_stages[key][stat_str].clamp(-6, 6)
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
      user_pokemon.save!
    end
  end
  
  def save_both
    user_pokemon_1.save!
    user_pokemon_2.save!
  end
end
