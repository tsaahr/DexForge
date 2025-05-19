class UserPokemon < ApplicationRecord
  belongs_to :user
  belongs_to :pokemon
  belongs_to :wild_pokemon, optional: true
  has_many :pokemon_status_effects, dependent: :destroy
  has_many :status_effects, through: :pokemon_status_effects
  has_one :healing_session, dependent: :destroy


  validates :level, presence: true, numericality: { greater_than: 0 }
  validates :experience, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_create :assign_random_ivs
  before_save :check_evolution!
  before_create :calculate_stats

  def ensure_only_one_selected
    UserPokemon.where(user_id: self.user_id).update_all(selected: false)
  end

  def name_or_nickname
    nickname.present? ? nickname : pokemon.name
  end

  def healing?
    healing_session.present?
  end

  def available_for_battle?
    !healing?
  end

  def assign_random_ivs
    self.hp_iv = rand(0..100)
    self.attack_iv = rand(0..100)
    self.defense_iv = rand(0..100)
    self.sp_attack_iv = rand(0..100)
    self.sp_defense_iv = rand(0..100)
    self.speed_iv = rand(0..100)
  end

  def gain_experience(amount)
    self.experience += amount
    leveled_up = false
    level_limit = 100
  
    while experience >= xp_needed_for_next_level && self.level < level_limit
      self.experience -= xp_needed_for_next_level
      self.level += 1
      leveled_up = true
      check_evolution!
    end
  
    calculate_stats if leveled_up
    save
    leveled_up
  end
  
  def xp_needed_for_next_level
    50 + (level * 10)
  end
  
  def select_best_moves
    moves_for_level.first(4)
  end
  
  def moves_for_level
    pokemon.pokemon_moves.includes(:move).select do |pm|
      pm.level_learned_at.nil? || pm.level_learned_at <= level
    end.map do |pm|
      move = pm.move
      {
        name: move.name,
        power: move.power,
        accuracy: move.accuracy,
        pp: move.pp,
        move_type: move.move_type,
        damage_class: move.damage_class,
        description: move.description
      }
    end.sort_by { |m| -(m[:power] || 0) }
  end
  

  def calculate_stats
    return unless pokemon

    self.hp         = stat_formula(base_stat("hp"), level, hp_iv, true)
    self.attack     = stat_formula(base_stat("attack"), level, attack_iv)
    self.defense    = stat_formula(base_stat("defense"), level, defense_iv)
    self.sp_attack  = stat_formula(base_stat("special-attack"), level, sp_attack_iv)
    self.sp_defense = stat_formula(base_stat("special-defense"), level, sp_defense_iv)
    self.speed      = stat_formula(base_stat("speed"), level, speed_iv)
    self.current_hp = hp
    
  end

  def stat_formula(base, level, iv, is_hp = false)
    if is_hp
      (((base * 2 + iv) * level) / 100) + level + 10
    else
      (((base * 2 + iv) * level) / 100) + 5
    end
  end  

  def base_stat(stat_name)
    pokemon.stats.find { |s| s["stat"]["name"] == stat_name }["base_stat"]
  end


  def self.build_with_best_moves(user:, pokemon:, level:)
    user_pokemon = new(user: user, pokemon: pokemon, level: level, experience: 0)
    user_pokemon.assign_random_ivs
    user_pokemon.calculate_stats
    user_pokemon.moves = user_pokemon.select_best_moves
    user_pokemon.current_hp = user_pokemon.hp
    user_pokemon
  end
  

  def generate_stats!
    calculate_stats
    save!
  end

  private

  def check_evolution!
    return unless pokemon.evolution_level.present?
    return unless level >= pokemon.evolution_level
    return unless pokemon.evolution_method == "level-up"
  
    if pokemon.evolution
      self.pokemon = pokemon.evolution
      puts "#{pokemon.name} evolved into #{self.pokemon.name}!"
    end    
  end
end
