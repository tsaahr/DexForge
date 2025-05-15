class WildPokemon < ApplicationRecord
  belongs_to :pokemon

  def generate_stats_from_base
    return unless pokemon && level

    stats = {}
    pokemon.stats.each do |s|
      name = s["stat"]["name"]
      base = s["base_stat"]

      value = if name == "hp"
                (((2 * base) * level) / 100) + level + 10
              else
                (((2 * base) * level) / 100) + 5
              end

      stats[name] = value
    end

    self.hp         = stats["hp"]
    self.current_hp = stats["hp"]
    self.attack     = stats["attack"]
    self.defense    = stats["defense"]
    self.sp_attack  = stats["special-attack"]
    self.sp_defense = stats["special-defense"]
    self.speed      = stats["speed"]
  end

  def select_best_moves
    moves_for_level.first(4)
  end

  def all_possible_moves
    moves_for_level
  end

  def self.build_with_best_moves(pokemon:, level:)
    wild_pokemon = WildPokemon.new(pokemon: pokemon, level: level)
    wild_pokemon.moves = wild_pokemon.select_best_moves
    wild_pokemon.send(:generate_stats_from_base)
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
