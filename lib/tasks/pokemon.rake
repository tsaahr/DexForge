namespace :pokemon do
  desc "Update evolution line"
  task update_evolutions: :environment do
    require 'httparty'

    Pokemon.all.each do |pokemon|
      begin
        species_data = HTTParty.get("https://pokeapi.co/api/v2/pokemon-species/#{pokemon.name}").parsed_response
        evo_url = species_data["evolution_chain"]["url"]
        chain_data = HTTParty.get(evo_url).parsed_response["chain"]

        current_node = find_node(chain_data, pokemon.name)
        next unless current_node

        next_evo = current_node["evolves_to"].first
        next unless next_evo

        next_name = next_evo["species"]["name"]
        evo_details = next_evo["evolution_details"].first
        min_level = evo_details["min_level"] if evo_details
        method = evo_details["trigger"]["name"] if evo_details && evo_details["trigger"]

        target_pokemon = Pokemon.find_by(name: next_name)
        next unless target_pokemon

        pokemon.update!(
          evolves_to: target_pokemon,
          evolution_level: min_level,
          evolution_method: method
        )

        target_pokemon.update!(evolves_from_id: pokemon.id)

        puts "Update: #{pokemon.name} => #{next_name} (nível #{min_level || '???'}, método: #{method || '???'})"

      rescue => e
        puts "Error #{pokemon.name}: #{e.message}"
      end
    end
  end

  def find_node(node, name)
    return node if node["species"]["name"] == name

    node["evolves_to"].each do |child|
      found = find_node(child, name)
      return found if found
    end

    nil
  end
end
