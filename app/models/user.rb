class User < ApplicationRecord
  has_many :user_pokemons, dependent: :destroy
  has_many :pokemons, through: :user_pokemons
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :validatable

end
