require 'net/http'
require 'json'

class PokedexController < ApplicationController
  def index
    @types = Pokemon.pluck(:types).flatten.uniq.sort
    @pokemons = Pokemon.order(:pokeapi_id)

    if params[:query].present?
      @pokemons = @pokemons.where("name ILIKE ?", "%#{params[:query]}%")
    end

    if params[:type].present? && params[:type] != "all"
      @pokemons = @pokemons.where("types @> ARRAY[?]::varchar[]", [params[:type]])
    end
  end

  def show
    name = params[:id].to_s.strip.downcase
    
    @pokemon = Pokemon.find_by(name: name)
  
    response = HTTParty.get("https://pokeapi.co/api/v2/pokemon/#{@pokemon.pokeapi_id}")
    if response.success?
      @pokemon_api = JSON.parse(response.body)
    else
      @pokemon_api = nil
    end
  
  end
  
  
end
