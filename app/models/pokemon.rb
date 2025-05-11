class Pokemon < ApplicationRecord

  has_many :user_pokemons, dependent: :destroy
  has_many :users, through: :user_pokemons
  belongs_to :evolves_to, class_name: 'Pokemon', optional: true
  has_many :pre_evolutions, class_name: 'Pokemon', foreign_key: 'evolves_to_id'

  def self.fetch_or_create_by_name(name)
    normalized_name = name.strip.downcase
    Rails.logger.debug ">>> Fetching API for: #{normalized_name}"
  
    pokemon = find_by(name: normalized_name)
    return pokemon if pokemon
  
    pokemon_response = HTTParty.get("https://pokeapi.co/api/v2/pokemon/#{normalized_name}")
    species_response = HTTParty.get("https://pokeapi.co/api/v2/pokemon-species/#{normalized_name}")
  
    Rails.logger.debug ">>> Pokemon API success? #{pokemon_response.success?}"
    Rails.logger.debug ">>> Species API success? #{species_response.success?}"
  
    if pokemon_response.success? && species_response.success?
      data = pokemon_response.parsed_response
      species = species_response.parsed_response
  
      create!(
        name: data["name"],
        image_url: data["sprites"]["other"]["official-artwork"]["front_default"],
        pokeapi_id: data["id"],
        height: data["height"],
        weight: data["weight"],
        base_experience: data["base_experience"],
        types: data["types"].map { |t| t["type"]["name"] },
        stats: data["stats"],
        abilities: data["abilities"].map { |a| { "ability" => { "name" => a["ability"]["name"] }, "is_hidden" => a["is_hidden"] } },
        moves: data["moves"].map { |m| { "move" => { "name" => m["move"]["name"] } } },
        sprites: data["sprites"],
        flavor_text: species["flavor_text_entries"].find { |e| e["language"]["name"] == "en" }&.dig("flavor_text")&.gsub(/\f/, " ")
      )
    else
      nil
    end
  end
  
end
