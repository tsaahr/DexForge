class CaptureController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_starter_chosen
  
  def index
  end

  def encounter
    wild_level = rand(5..40)

    base_pokemon = Pokemon.where(evolves_from: nil, is_legendary: false, is_mythical: false).sample

    evolved_pokemon = if rand < 0.2
      base_pokemon.auto_evolve_for_level!(wild_level)
    else
      base_pokemon
    end

    @wild_pokemon = OpenStruct.new(
      name: evolved_pokemon.name,
      level: wild_level,
      sprite: evolved_pokemon.image_url
    )
  end
end
