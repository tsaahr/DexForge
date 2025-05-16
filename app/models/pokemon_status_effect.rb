class PokemonStatusEffect < ApplicationRecord
  belongs_to :user_pokemon
  belongs_to :status_effect

  validates :remaining_turns, numericality: { greater_than_or_equal_to: 0 }
end
