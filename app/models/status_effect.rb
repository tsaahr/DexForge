class StatusEffect < ApplicationRecord
  has_many :move_status_effects, dependent: :destroy
  has_many :moves, through: :move_status_effects
end
