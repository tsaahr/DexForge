class PokedexController < ApplicationController
  def index
    @pokemons = Pokemon.all.order(:pokeapi_id)
  end

  def show
    response = HTTParty.get("https://pokeapi.co/api/v2/pokemon/#{params[:name]}")
    @pokemon = JSON.parse(response.body)
  end
end
