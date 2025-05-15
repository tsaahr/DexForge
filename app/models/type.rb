class Type < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  has_many :pokemon_types
  has_many :pokemons, through: :pokemon_types
  has_many :moves
end
