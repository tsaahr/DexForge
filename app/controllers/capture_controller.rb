class CaptureController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_starter_chosen
  
  def index
  end

  def encounter
    wild_level = rand(5..40)
    base_pokemon = Pokemon.where(evolves_from: nil, is_legendary: false, is_mythical: false).sample
    evolved = rand < 0.2 ? base_pokemon.auto_evolve_for_level!(wild_level) : base_pokemon
  
  
    best_moves = fetch_best_moves(evolved, wild_level)
    scaled_stats = extract_scaled_stats(evolved, wild_level)

    @wild_pokemon = WildPokemon.create!(
      pokemon: evolved,
      level: wild_level,
      hp: scaled_stats["hp"],
      current_hp: scaled_stats["hp"],
      attack: scaled_stats["attack"],
      defense: scaled_stats["defense"],
      sp_attack: scaled_stats["special-attack"],
      sp_defense: scaled_stats["special-defense"],
      speed: scaled_stats["speed"],
      moves: best_moves
    )    
    
  end

  def show
    @wild_pokemon = WildPokemon.find(params[:id])
    @all_moves = fetch_best_moves_for_frontend(@wild_pokemon.pokemon)
  end
  def battle
    @wild_pokemon = WildPokemon.find(params[:id])
    @all_moves = fetch_best_moves(@wild_pokemon.pokemon, @wild_pokemon.level)
  end
  
  

  def try_capture
    wild_pokemon = WildPokemon.find(params[:id])
  
    if captured?
      user_pokemon = UserPokemon.create!(
        user: current_user,
        pokemon: wild_pokemon.pokemon,
        wild_pokemon: wild_pokemon,
        level: wild_pokemon.level,
        experience: 0
      )
      render json: { captured: true, user_pokemon_id: user_pokemon.id }
    else
      render json: { captured: false }
    end
  end
  

  private

    
  def fetch_best_moves(pokemon, level)
    pokemon_moves = pokemon.pokemon_moves.includes(:move)
  
    return [] if pokemon_moves.blank?
  
    available_moves = pokemon_moves.select do |pokemon_move|
      pokemon_move.level_learned_at.nil? || pokemon_move.level_learned_at <= level
    end

    move_objects = available_moves.map do |pokemon_move|
      move = pokemon_move.move
      {
        name: move.name,
        power: move.power,
        accuracy: move.accuracy,
        pp: move.pp,
        move_type: move.move_type,
        damage_class: move.damage_class,
        description: move.description
      }
    end
    move_objects.sort_by { |m| -(m[:power] || 0) }.first(4)
  end
  
  
  def extract_scaled_stats(pokemon, level)
    stats = {
      "hp" => 0,
      "attack" => 0,
      "defense" => 0,
      "special-attack" => 0,
      "special-defense" => 0,
      "speed" => 0
    }
  
    pokemon.stats.each do |s|
      name = s["stat"]["name"]
      base = s["base_stat"]
  
      if name == "hp"
        stats["hp"] = (((2 * base) * level) / 100) + level + 10
      else
        stats[name] = (((2 * base) * level) / 100) + 5
      end
    end
  
    stats
  end
  
  
end
