class MyPokemonsController < ApplicationController
  before_action :authenticate_user!

  def index
    @user_pokemons = UserPokemon.where(user: current_user).includes(:pokemon)
  
    @user_pokemons.each do |user_pokemon|
      if user_pokemon.moves.blank?
        user_pokemon.moves = user_pokemon.select_best_moves
        user_pokemon.save
      end
    end
  end
  

  def destroy
    @pokemon = current_user.pokemons.find(params[:id])
    @pokemon.destroy
    redirect_to my_pokemons_path, notice: "Pokémon released successfully."
  end
end
