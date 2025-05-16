class WildPokemon < ApplicationRecord
  belongs_to :pokemon
  before_create :assign_random_ivs

  def assign_random_ivs
    self.hp_iv         = rand(0..100)
    self.attack_iv     = rand(0..100)
    self.defense_iv    = rand(0..100)
    self.sp_attack_iv  = rand(0..100)
    self.sp_defense_iv = rand(0..100)
    self.speed_iv      = rand(0..100)
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
  

  def generate_stats_from_base
    return unless pokemon && level
  
    self.hp         = stat_formula(base_stat("hp"), level, hp_iv, true)
    self.current_hp = hp
    self.attack     = stat_formula(base_stat("attack"), level, attack_iv)
    self.defense    = stat_formula(base_stat("defense"), level, defense_iv)
    self.sp_attack  = stat_formula(base_stat("special-attack"), level, sp_attack_iv)
    self.sp_defense = stat_formula(base_stat("special-defense"), level, sp_defense_iv)
    self.speed      = stat_formula(base_stat("speed"), level, speed_iv)
  end
  

  def select_best_moves
    moves_for_level.first(4)
  end

  def all_possible_moves
    moves_for_level
  end

  def self.build_with_best_moves(pokemon:, level:)
    wild_pokemon = WildPokemon.new(pokemon: pokemon, level: level)
    wild_pokemon.assign_random_ivs
    wild_pokemon.generate_stats_from_base
    wild_pokemon.moves = wild_pokemon.select_best_moves
    wild_pokemon
  end
  

  private

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
end
