class Pokemon < ApplicationRecord
  def self.fetch_or_create(id)
    find_by(pokeapi_id: id) || begin
      response = HTTParty.get("https://pokeapi.co/api/v2/pokemon/#{id}")
      if response.success?
        data = response.parsed_response

            
        create!(
          name: data["name"],
          image_url: data["sprites"]["front_default"],
          pokeapi_id: id
          
        )
      end
    end
  end
end
