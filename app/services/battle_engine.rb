class BattleEngine
  def initialize(battle, attacker_move:, defender_move:, attacker:, defender:)
    @battle = battle
    @attacker = attacker
    @defender = defender
    @attacker_move = attacker_move
    @defender_move = defender_move
  end

  def execute_turn!
    return if @battle.finished?
  
    turn_number = @battle.battle_turns.maximum(:turn_number).to_i + 1
  
    first, second = decide_turn_order
  
    first_move = move_for(first)
    second_move = move_for(second)
  
    process_attack(attacker: first, defender: second, move: first_move, turn_number: turn_number)
    return if @battle.finished?
  
    process_attack(attacker: second, defender: first, move: second_move, turn_number: turn_number)
  
    @battle.increment!(:turn) unless @battle.finished?
  end
  

  private

  def pokemon_1
    @battle.respond_to?(:user_pokemon_1) ? @battle.user_pokemon_1 : @battle.user_pokemon
  end
  
  def pokemon_2
    @battle.respond_to?(:user_pokemon_2) ? @battle.user_pokemon_2 : @battle.wild_pokemon
  end
  

  def decide_turn_order
    speed_1 = @attacker.pokemon.stats.find { |s| s["stat"]["name"] == "speed" }["base_stat"]
    speed_2 = @defender.pokemon.stats.find { |s| s["stat"]["name"] == "speed" }["base_stat"]    

    if speed_1 > speed_2
      [pokemon_1, pokemon_2]
    elsif speed_2 > speed_1
      [pokemon_2, pokemon_1]
    else
      [pokemon_1, pokemon_2].shuffle
    end    
  end

  def move_for(pokemon)
    pokemon == pokemon_1 ? @attacker_move : @defender_move
  end  

  def process_attack(attacker:, defender:, move:, turn_number:)
    attacker.reload
    defender.reload
  
    if accuracy_check?(attacker, defender, move)
      apply_stat_changes!(move, attacker, defender)
      damage = calculate_damage(attacker, defender, move)
    else
      damage = 0
    end
  
    defender.current_hp -= damage
    defender.current_hp = 0 if defender.current_hp < 0
    defender.save!
  
    @battle_turn = BattleTurn.create!(
      battleable: @battle,
      attacker: attacker,
      defender: defender,
      damage: damage,
      turn_number: turn_number
    )

    @logger ||= BattleLogger.new(@battle)
    @logger.log_attack(
      attacker: attacker,
      move: move,
      defender: defender,
      damage: damage,
      turn: turn_number
    )

    if defender.current_hp <= 0
      @battle.update!(status: :finished, winner: attacker)

      if attacker.is_a?(UserPokemon)
        xp_gained = defender.level * 10
        attacker.gain_experience(xp_gained)
      end
    end
  end
  

  def apply_stat_changes!(move, attacker, defender)
    return unless move["damage_class"] == "status"
  
    (move["stat_changes"] || []).each do |change|
      target = move_targets_self?(move) ? attacker : defender
      stat = change["stat"]["name"]
      amount = change["change"]
  
      apply_stage_change!(target, stat, amount)
    end
  end  

  def apply_stage_change!(pokemon, stat, change_amount)
    key = pokemon.id.to_s
    @battle.stat_stages[key] ||= @battle.base_stage_hash
    @battle.stat_stages[key][stat] ||= 0
    @battle.stat_stages[key][stat] += change_amount
    @battle.stat_stages[key][stat] = @battle.stat_stages[key][stat].clamp(-6, 6)
    @battle.save!
  end

  def calculate_damage(attacker, defender, move)
    return 0 if move.nil? || move["power"].nil? || move["power"] <= 0
  
    if move["damage_class"] == "physical"
      atk = modified_stat(attacker, attacker.attack, :attack)
      def_stat = modified_stat(defender, defender.defense, :defense)
    elsif move["damage_class"] == "special"
      atk = modified_stat(attacker, attacker.sp_attack, :sp_attack)
      def_stat = modified_stat(defender, defender.sp_defense, :sp_defense)
    else
      return 0
    end
  
    stab = attacker.pokemon.types.include?(move["move_type"]) ? 1.5 : 1.0
    effectiveness = type_effectiveness_multiplier(move, defender)
    random_factor = rand(0.85..1.0)
    level = attacker.level
  
    base = (((((2 * level) / 5.0 + 2) * move["power"] * (atk.to_f / def_stat)) / 50.0) + 2)
    (base * stab * effectiveness * random_factor).floor
  end  

  def modified_stat(pokemon, base_stat, stat_symbol)
    stage = @battle.stat_stage(pokemon, stat_symbol.to_s)
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

  def type_effectiveness_multiplier(move, defender)
    attack_type = move["move_type"]
    return 1.0 unless attack_type && defender.pokemon.types.any?
  
    defender.pokemon.types.reduce(1.0) do |total, def_type|
      effectiveness = TypeEffectiveness.find_by(
        attacking_type: attack_type,
        defending_type: def_type
      )
      total * (effectiveness&.multiplier || 1.0)
    end
  end  

  def accuracy_check?(attacker, defender, move)
    acc_stage = @battle.stat_stage(attacker, "accuracy")
    eva_stage = @battle.stat_stage(defender, "evasion")

    final_accuracy = move["accuracy"] * (1 + acc_stage * 0.1 - eva_stage * 0.1) || 100
    final_accuracy = final_accuracy.clamp(1, 100) || 100
    rand(100) < final_accuracy
  end

  def move_targets_self?(move)
    move["damage_class"] == "status"
  end  

  def self.perform_attack(attacker:, defender:, move:, stat_stages:)
    stages = stat_stages.dup
  
    acc = BattleEngine.accuracy_check?(attacker, defender, move, stages)
    log = "#{attacker.name_or_nickname} used #{move.name}..."
  
    if acc
      apply_stat_changes!(move, attacker, defender, stages)
      damage = BattleEngine.calculate_damage(attacker, defender, move, stages)
      defender.current_hp -= damage
      defender.current_hp = 0 if defender.current_hp < 0
      defender.save!
      log += " and dealt #{damage} damage!"
    else
      damage = 0
      log += " but missed!"
    end
  
    [damage, log, stages]
  end
  
end
