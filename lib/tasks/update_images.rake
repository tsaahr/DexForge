namespace :pokemon_db do
  desc "Atualiza apenas a imagem (image_url) de todos os Pokémons usando a PokéAPI"
  task update_images: :environment do
    puts "Atualizando imagens dos Pokémons..."

    Pokemon.find_each do |pokemon|
      begin
        puts "Atualizando imagem do Pokémon ##{pokemon.pokeapi_id || pokemon.id} - #{pokemon.name}..."

        response = HTTParty.get("https://pokeapi.co/api/v2/pokemon/#{pokemon.pokeapi_id || pokemon.id}")

        if response.success?
          image_url = response.dig("sprites", "other", "official-artwork", "front_default")
          if image_url.present?
            pokemon.update!(image_url: image_url)
            puts "→ OK"
          else
            puts "→ Nenhuma imagem encontrada."
          end
        else
          puts "→ Erro ao buscar dados na API."
        end

      rescue => e
        puts "Erro ao atualizar o Pokémon #{pokemon.name}: #{e.message}"
      end
    end

    puts "✅ Atualização de imagens concluída!"
  end
end
