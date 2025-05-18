class User < ApplicationRecord
  has_many :user_pokemons, dependent: :destroy
  has_many :pokemons, through: :user_pokemons
  has_one :selected_pokemon, -> { where(selected: true) }, class_name: "UserPokemon"
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :validatable

  def starter_chosen?
    user_pokemons.exists?
  end  

end
