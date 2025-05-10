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
    param = params[:id].to_s.strip.downcase

    if param.match?(/^\d+$/)
      @pokemon = Pokemon.find_by(pokeapi_id: param.to_i)
    else
      @pokemon = Pokemon.find_by(name: param)
    end
  
    response = HTTParty.get("https://pokeapi.co/api/v2/pokemon/#{@pokemon.pokeapi_id}")
    if response.success?
      @pokemon_api = JSON.parse(response.body)
    else
      @pokemon_api = nil
    end

    #moves diff
    @evolution_stage = get_evolution_stage(@pokemon.name)

    max_level = case @evolution_stage
    when 1 then 20
    when 2 then 40
    else 100
    end


    @sample_moves = @pokemon_api["moves"]
    .select do |move|
      move["version_group_details"].any? do |detail|
        detail["move_learn_method"]["name"] == "level-up" &&
        detail["level_learned_at"] <= max_level
      end
    end
    .uniq { |m| m["move"]["name"] }
    .first(5)
  
  @sample_moves = @sample_moves.map do |move|
    move_data = Move.find_by(name: move["move"]["name"])
  
    {
      name: move["move"]["name"],
      power: move_data&.power,
      description: move_data&.description
    }
    end
  end


  def get_evolution_stage(pokemon_name)
    species_response = HTTParty.get("https://pokeapi.co/api/v2/pokemon-species/#{pokemon_name}")
    return 1 unless species_response.success?
  
    species_data = JSON.parse(species_response.body)
    evolution_chain_url = species_data["evolution_chain"]["url"]
    
    chain_response = HTTParty.get(evolution_chain_url)
    return 1 unless chain_response.success?
  
    chain_data = JSON.parse(chain_response.body)
  
    stage = 1
    current = chain_data["chain"]
  
    loop do
      return stage if current["species"]["name"] == pokemon_name
  
      if current["evolves_to"].any?
        current = current["evolves_to"].first
        stage += 1
      else
        break
      end
    end
    stage
  end
  
  
  
  
end
