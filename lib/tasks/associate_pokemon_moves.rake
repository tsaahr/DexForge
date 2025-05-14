# lib/tasks/associate_pokemon_moves.rake
namespace :pokemon_moves do
  desc "Associa movimentos a pokémons"
  task associate: :environment do
    require 'httparty'

    Pokemon.find_each do |pokemon|
      puts "Associando movimentos para o Pokémon: #{pokemon.name}"

      response = HTTParty.get("https://pokeapi.co/api/v2/pokemon/#{pokemon.pokeapi_id}")
      next unless response.success?

      data = JSON.parse(response.body)
      moves = data["moves"]

      if moves.any?
        moves.each do |move_data|
          version_details = move_data["version_group_details"]

          level_up_detail = version_details.find do |detail|
            detail["move_learn_method"]["name"] == "level-up"
          end

          next unless level_up_detail

          level = level_up_detail["level_learned_at"]
          move_url = move_data["move"]["url"]
          move_response = HTTParty.get(move_url)
          move_data_parsed = JSON.parse(move_response.body)
          pokeapi_move_id = move_data_parsed["id"]

          move = Move.find_by(pokeapi_id: pokeapi_move_id)
          if move
            PokemonMove.find_or_create_by(pokemon: pokemon, move: move) do |pm|
              pm.level_learned_at = level
            end
            puts "→ Associado: #{move.name} (lvl #{level})"
          end
        end
      else
        puts "→ Nenhum movimento encontrado no JSON do Pokémon: #{pokemon.name}"
      end
    end
    puts "Associação de movimentos concluída!"
  end
end
