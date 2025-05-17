class Move < ApplicationRecord
  has_many :pokemon_moves
  has_many :pokemons, through: :pokemon_moves
  belongs_to :type
  enum category: { physical: 0, special: 1, status: 2 }
  has_many :stat_changes, dependent: :destroy
  has_many :move_status_effects, dependent: :destroy
  has_many :status_effects, through: :move_status_effects

  def physical?
    damage_class == 'physical'
  end

  def special?
    damage_class == 'special'
  end

end
