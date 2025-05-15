class Pokemon < ApplicationRecord

  has_many :user_pokemons, dependent: :destroy
  has_many :users, through: :user_pokemons
  belongs_to :evolves_from, class_name: 'Pokemon', optional: true
  has_one :evolution, class_name: 'Pokemon', foreign_key: :evolves_from
  has_many :pokemon_moves
  has_many :moves, through: :pokemon_moves
  has_many :pokemon_types
  has_many :types, through: :pokemon_types



  def self.fetch_or_update(id)
    pokemon_response = HTTParty.get("https://pokeapi.co/api/v2/pokemon/#{id}")
    species_response = HTTParty.get("https://pokeapi.co/api/v2/pokemon-species/#{id}")
  
    return unless pokemon_response.success? && species_response.success?
  
    data = pokemon_response.parsed_response
    species = species_response.parsed_response
  
    pokemon = find_or_initialize_by(pokeapi_id: id)
    pokemon.assign_attributes(
      name: data["name"],
      image_url: data["sprites"]["other"]["official-artwork"]["front_default"],
      height: data["height"],
      weight: data["weight"],
      base_experience: data["base_experience"],
      types: data["types"].map { |t| t["type"]["name"] },
      stats: data["stats"],
      abilities: data["abilities"].map { |a| { "ability" => { "name" => a["ability"]["name"] }, "is_hidden" => a["is_hidden"] } },
      moves: data["moves"].map { |m| { "move" => { "name" => m["move"]["name"] } } },
      sprites: data["sprites"],
      flavor_text: species["flavor_text_entries"].find { |e| e["language"]["name"] == "en" }&.dig("flavor_text")&.gsub(/\f/, " "),
      is_legendary: species["is_legendary"],
      is_mythical: species["is_mythical"]
    )
    pokemon.save!
  end 
  

  

  def evolved_form_for_level(current_level)
    Pokemon.find_by(evolves_from: self.name, evolution_level: ..current_level)
  end
  
  def auto_evolve_for_level!(level)
    current = self
    while current.evolution_level && current.evolution_level <= level && current.evolution.present?
      current = current.evolution
    end
    current
  end  
end
