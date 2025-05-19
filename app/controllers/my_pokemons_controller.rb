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

  def select
    @user_pokemon = current_user.user_pokemons.find(params[:id])

    current_user.user_pokemons.update_all(selected: false)

    if @user_pokemon.update(selected: true)
      redirect_to my_pokemons_path, notice: "#{@user_pokemon.pokemon.name.capitalize} was selected!"
    else
      redirect_to my_pokemons_path, alert: "Failed to select Pokémon."
    end
  end
  
  

  def destroy
    @user_pokemon = current_user.user_pokemons.find(params[:id])
    Battle.where("user_pokemon_1_id = ? OR user_pokemon_2_id = ?", @user_pokemon.id, @user_pokemon.id).destroy_all
    WildBattle.where(user_pokemon_id: @user_pokemon.id).destroy_all
    @user_pokemon.destroy
    redirect_to my_pokemons_path, notice: "Pokémon released successfully."
  end
  
end
