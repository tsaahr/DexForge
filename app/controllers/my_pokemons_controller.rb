class MyPokemonsController < ApplicationController
  before_action :authenticate_user!

  def index
    @user_pokemons = current_user.user_pokemons.includes(:pokemon)
  end

  def destroy
    @pokemon = current_user.pokemons.find(params[:id])
    @pokemon.destroy
    redirect_to my_pokemons_path, notice: "Pokémon released successfully."
  end
end
