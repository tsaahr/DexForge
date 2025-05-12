class StartersController < ApplicationController
  before_action :authenticate_user!

  def new
    @starter_options = %w[charmander bulbasaur squirtle]
  end

  def create
    pokemon_name = params[:pokemon]
    response = HTTParty.get("https://pokeapi.co/api/v2/pokemon/#{pokemon_name}")
    data = response.parsed_response

    pokemon = Pokemon.find_or_create_by!(pokeapi_id: data["id"]) do |p|
      p.name = data["name"]
      p.image_url = data["sprites"]["front_default"]
      p.base_experience = data["base_experience"]
      p.stats = data["stats"].map { |s| { "stat" => { "name" => s["stat"]["name"] }, "base_stat" => s["base_stat"] } }
      p.types = data["types"].map { |t| t["type"]["name"] }
    end

    UserPokemon.create!(
      user: current_user,
      pokemon: pokemon,
      level: 5,
      experience: 0
    )

    current_user.update!(starter_chosen: true)

    redirect_to root_path, notice: "Starter escolhido com sucesso!"
  end
end
