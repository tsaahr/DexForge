class PokedexController < ApplicationController
  def index
    @types = Pokemon.pluck(:types).flatten.uniq.sort
    @pokemons = Pokemon.all
    
    @pokemons = @pokemons.where("name ILIKE ?", "%#{params[:query]}%") if params[:query].present?
    
    if params[:type].present? && params[:type] != "all"
      @pokemons = @pokemons.select { |p| p.types.include?(params[:type]) }
    end
    
  end

  def show
    response = HTTParty.get("https://pokeapi.co/api/v2/pokemon/#{params[:id]}")
    if response.success?
      @pokemon = JSON.parse(response.body)
    else
      redirect_to pokedex_index_path, alert: "Pokémon not found."
    end
  end  
end
