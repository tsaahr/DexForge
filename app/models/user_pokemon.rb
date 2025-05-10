class UserPokemon < ApplicationRecord
  belongs_to :user
  belongs_to :pokemon

  validates :level, presence: true, numericality: { greater_than: 0 }
  validates :experience, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_create :assign_random_ivs

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
  
    while experience >= xp_needed_for_next_level
      self.experience -= xp_needed_for_next_level
      self.level += 1
      leveled_up = true
    end
  
    calculate_stats if leveled_up
    save
    leveled_up
  end
  
  def xp_needed_for_next_level
    50 + (level * 10)
  end
  

  def pokemon_api_data
    @pokemon_api_data ||= begin
      response = HTTParty.get("https://pokeapi.co/api/v2/pokemon/#{pokemon.pokeapi_id}")
      response.success? ? JSON.parse(response.body) : nil
    end
  end

  def available_moves
    return [] unless pokemon_api_data

    pokemon_api_data["moves"]
      .select do |move|
        move["version_group_details"].any? do |detail|
          detail["move_learn_method"]["name"] == "level-up" &&
          detail["level_learned_at"] <= level &&
          detail["level_learned_at"] > 0
        end
      end
      .uniq { |m| m["move"]["name"] }
      .map do |move|
        move_data = Move.find_by(name: move["move"]["name"])
        {
          name: move["move"]["name"],
          power: move_data&.power,
          description: move_data&.description
        }
      end
  end

  IV = 15

  def calculate_stats
    return unless pokemon

    self.hp         = stat_formula(base_stat("hp"), level, true)
    self.attack     = stat_formula(base_stat("attack"), level)
    self.defense    = stat_formula(base_stat("defense"), level)
    self.sp_attack  = stat_formula(base_stat("special-attack"), level)
    self.sp_defense = stat_formula(base_stat("special-defense"), level)
    self.speed      = stat_formula(base_stat("speed"), level)
  end

  def stat_formula(base, level, is_hp = false)
    if is_hp
      (((base * 2 + hp_iv) * level) / 100) + level + 10
    else
      (((base * 2 + attack_iv) * level) / 100) + 5
    end
  end

  def base_stat(stat_name)
    pokemon.stats.find { |s| s["stat"]["name"] == stat_name }["base_stat"]
  end

end
