require 'httparty'

namespace :pokemon do
  desc "Atualiza tipos dos pokemons buscando na PokeAPI"
  task update_types_from_api: :environment do
    Pokemon.find_each do |pokemon|
      puts "Buscando tipos para #{pokemon.name}..."

      response = HTTParty.get("https://pokeapi.co/api/v2/pokemon/#{pokemon.name.downcase}")
      if response.success?
        types = response.parsed_response["types"].map { |t| t["type"]["name"].capitalize }
        
        pokemon.types.clear

        types.each do |type_name|
          type = Type.find_or_create_by(name: type_name)
          pokemon.types << type unless pokemon.types.include?(type)
        end

        pokemon.save!
        puts "Atualizado #{pokemon.name} com tipos: #{types.join(', ')}"
      else
        puts "Falha ao buscar dados para #{pokemon.name}"
      end
    end
  end
end
