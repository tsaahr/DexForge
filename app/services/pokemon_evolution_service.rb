require 'httparty'

class PokemonEvolutionService
  BASE_URL = "https://pokeapi.co/api/v2"

  def initialize(pokemon_name)
    @pokemon_name = pokemon_name.downcase
  end

  def next_evolution_for_level(current_level)
    chain = evolution_chain
    node = find_current_node(chain["chain"])
    return nil unless node

    next_evo = node["evolves_to"].find do |evo|
      details = evo["evolution_details"].first
      details && details["min_level"] && current_level >= details["min_level"]
    end

    next_evo ? next_evo["species"]["name"] : nil
  end

  private

  def species_data
    HTTParty.get("#{BASE_URL}/pokemon-species/#{@pokemon_name}").parsed_response
  end

  def evolution_chain
    url = species_data["evolution_chain"]["url"]
    HTTParty.get(url).parsed_response
  end

  def find_current_node(node)
    return node if node["species"]["name"] == @pokemon_name

    node["evolves_to"].each do |child|
      found = find_current_node(child)
      return found if found
    end

    nil
  end
end