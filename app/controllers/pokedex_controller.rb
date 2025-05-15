require 'net/http'
require 'json'

class PokedexController < ApplicationController
  def index
    @types = Type.pluck(:name).sort
    @pokemons = Pokemon.includes(:types).order(:pokeapi_id)
  
    if params[:query].present?
      @pokemons = @pokemons.where("name ILIKE ?", "%#{params[:query]}%")
    end
  
    if params[:type].present? && params[:type] != "all"
      @pokemons = @pokemons.joins(:types).where(types: { name: params[:type] })
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
    @all_moves = @pokemon_api["moves"]
    .select do |move|
      move["version_group_details"].any? do |detail|
        detail["move_learn_method"]["name"] == "level-up"
      end
    end
    .uniq { |m| m["move"]["name"] }
    .map do |move|
      move_data = Move.find_by(name: move["move"]["name"])
      level_detail = move["version_group_details"].find do |detail|
        detail["move_learn_method"]["name"] == "level-up"
      end
  
      {
        name: move["move"]["name"],
        level: level_detail["level_learned_at"],
        power: move_data&.power,
        accuracy: move_data&.accuracy,
        pp: move_data&.pp,
        move_type: move_data&.move_type,
        damage_class: move_data&.damage_class,
        description: move_data&.description
      }
    end
  end  
end
