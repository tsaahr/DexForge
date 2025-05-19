class WildBattle < ApplicationRecord
  belongs_to :user_pokemon
  belongs_to :wild_pokemon
  belongs_to :winner, polymorphic: true, optional: true
  has_many :battle_turns, dependent: :destroy
  has_many :battle_logs, as: :battle, dependent: :destroy
  has_many :battle_logs, as: :battleable
  has_many :wild_battles, dependent: :destroy



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
      stat_stages: default_stat_stages,
      current_turn: :user
    )

    initialize_current_hp(user_pokemon)
    initialize_current_hp(wild_pokemon)
    save_both
  end

  def execute_turn!
    return if finished?
  
    attacker, defender = current_turn == "user" ? [user_pokemon, wild_pokemon] : [wild_pokemon, user_pokemon]
  
    attacker_move = choose_move(attacker)
    defender_move = choose_move(defender)
  
    engine = BattleEngine.new(
      self,
      attacker_move: attacker_move,
      defender_move: defender_move,
      attacker: attacker,
      defender: defender
    )
    
    engine.execute_turn!
  
    toggle_turn! unless finished?
    increment!(:turn)
  end
  
  def choose_move(pokemon)
    pokemon.moves.sample
  end
  

  def stat_stage(pokemon, stat)
    stages = stat_stages[pokemon.id.to_s] || base_stage_hash
    stages[stat.to_s] || 0
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
      user_pokemon.id.to_s => base_stage_hash.dup,
      wild_pokemon.id.to_s => base_stage_hash.dup
    }
  end

  def ongoing?
    user_pokemon.current_hp.to_i > 0 && wild_pokemon.current_hp.to_i > 0
  end

  def finished?
    !ongoing? || status == "finished"
  end

  def toggle_turn!
    self.current_turn = current_turn == "user" ? "wild" : "user"
    save!
  end

  def reset_health!
    user_pokemon.update!(current_hp: user_pokemon.hp)
    wild_pokemon.update!(current_hp: wild_pokemon.hp)
    update!(status: :pending, turn: nil, winner: nil)
  end

  private

  def initialize_current_hp(pokemon)
    if pokemon.current_hp.nil?
      pokemon.current_hp = pokemon.hp
      pokemon.save!
    end
  end

  def save_both
    user_pokemon.save!
    wild_pokemon.save!
  end
end
