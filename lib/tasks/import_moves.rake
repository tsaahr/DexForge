namespace :import do
  desc "Importa todos os moves da PokéAPI"
  task moves: :environment do
    require 'httparty'

    def fetch_move_data(id)
      response = HTTParty.get("https://pokeapi.co/api/v2/move/#{id}")
      if response.success?
        data = JSON.parse(response.body)

        Move.find_or_create_by(pokeapi_id: data["id"]) do |move|
          move.name = data["name"]
          move.move_type = data["type"]["name"]
          move.damage_class = data["damage_class"]["name"]
          move.power = data["power"]
          move.accuracy = data["accuracy"]
          move.pp = data["pp"]
          move.description = data["flavor_text_entries"]
            .find { |entry| entry["language"]["name"] == "en" }&.dig("flavor_text") || "No description available"
        end
        puts "Move #{id}: #{data['name']} imported."
      else
        puts "Error fetching move #{id}."
      end
    end
    total_moves = 10000
    (1..total_moves).each do |id|
      fetch_move_data(id)
      sleep(0.2)
    end
    puts "Importação de moves finalizada!"
  end
end
