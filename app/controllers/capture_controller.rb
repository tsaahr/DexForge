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
      user_pokemon = UserPokemon.new(
        user: current_user,
        pokemon: wild_pokemon.pokemon,
        wild_pokemon: wild_pokemon,
        level: wild_pokemon.level,
        experience: 0,
  
        hp_iv: wild_pokemon.hp_iv,
        attack_iv: wild_pokemon.attack_iv,
        defense_iv: wild_pokemon.defense_iv,
        sp_attack_iv: wild_pokemon.sp_attack_iv,
        sp_defense_iv: wild_pokemon.sp_defense_iv,
        speed_iv: wild_pokemon.speed_iv,
  
        hp: wild_pokemon.hp,
        current_hp: wild_pokemon.current_hp,
        attack: wild_pokemon.attack,
        defense: wild_pokemon.defense,
        sp_attack: wild_pokemon.sp_attack,
        sp_defense: wild_pokemon.sp_defense,
        speed: wild_pokemon.speed
      )
  
      user_pokemon.save!
      render json: { captured: true, user_pokemon_id: user_pokemon.id }
    else
      render json: { captured: false }
    end
  end
  
end
