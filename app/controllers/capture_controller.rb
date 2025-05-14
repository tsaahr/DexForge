class CaptureController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_starter_chosen
  
  def index
  end

  def encounter
    wild_level = rand(5..40)
    base_pokemon = Pokemon.where(evolves_from: nil, is_legendary: false, is_mythical: false).sample
    evolved = rand < 0.2 ? base_pokemon.auto_evolve_for_level!(wild_level) : base_pokemon
  
    max_hp = 100 + rand(0..50)
  
    best_moves = fetch_best_moves(evolved, wild_level)
    stats = extract_stats(evolved)
  

    @wild_pokemon = WildPokemon.create!(
      pokemon: evolved,
      level: wild_level,
      max_hp: max_hp,
      current_hp: max_hp,
      moves: best_moves,
      stats: stats
    )
  
    if captured?
      UserPokemon.create!(
        user: current_user,          
        pokemon: evolved,             
        wild_pokemon: @wild_pokemon,  
        level: wild_level,            
        experience: 0                 
      )
    end
  end

  def show
    @wild_pokemon = WildPokemon.find(params[:id])
    @all_moves = fetch_best_moves_for_frontend(@wild_pokemon.pokemon)
  end


  def captured?
    rand < 0.1  
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
  
  
  
  def extract_stats(pokemon)
    stats = {}
    pokemon.stats.each do |s|
      stat_name = s["stat"]["name"]
      base_stat = s["base_stat"]
      stats[stat_name] = base_stat
    end
    stats
  end
  
end
