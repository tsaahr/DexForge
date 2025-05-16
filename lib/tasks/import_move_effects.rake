namespace :pokemon do
  desc "Importa efeitos de status e mudanças de stat dos moves já existentes"
  task import_move_effects: :environment do
    require 'net/http'
    require 'json'

    puts "Iniciando importação de efeitos dos moves..."

    Move.find_each do |move|
      next unless move.pokeapi_id

      url = URI("https://pokeapi.co/api/v2/move/#{move.pokeapi_id}/")
      response = Net::HTTP.get(url)
      move_data = JSON.parse(response)

      ailment = move_data.dig("meta", "ailment", "name")
      ailment_chance = move_data.dig("meta", "ailment_chance") || 100

      if ailment && ailment != "none"
        effect = StatusEffect.find_or_create_by!(name: ailment) do |se|
          se.effect_type = "status"
          se.duration = nil 
          se.description = move_data["effect_entries"].find { |e| e["language"]["name"] == "en" }&.dig("effect")
        end

        puts "  → Status effect registrado: #{effect.name} (#{move.name})"
      end

      move_data["stat_changes"].each do |stat_change|
        stat_name = stat_change["stat"]["name"]
        change_value = stat_change["change"]

        StatChange.find_or_create_by!(move_id: move.id, stat_name: stat_name, change: change_value)

        puts "  → StatChange registrado: #{move.name} altera #{stat_name} em #{change_value}"
      end

      sleep 0.3
    end

    puts "Importação concluída!"
  end
end
