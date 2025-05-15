class CaptureController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_starter_chosen
  
  def index
  end

  def encounter
    wild_level = rand(5..40)
    base_pokemon = Pokemon.where(evolves_from: nil, is_legendary: false, is_mythical: false).sample
    evolved = rand < 0.2 ? base_pokemon.auto_evolve_for_level!(wild_level) : base_pokemon
  
    @wild_pokemon = WildPokemon.build_with_best_moves(pokemon: evolved, level: wild_level)
    @wild_pokemon.save!
  end
  
  
  def show
    @wild_pokemon = WildPokemon.find(params[:id])
    @all_moves = @wild_pokemon.all_possible_moves
  end
  def battle
    @wild_pokemon = WildPokemon.find(params[:id])
    @all_moves = @wild_pokemon.all_possible_moves
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
end
