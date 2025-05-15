class TypeEffectiveness < ApplicationRecord
  belongs_to :attacking_type, class_name: "Type"
  belongs_to :defending_type, class_name: "Type"

  validates :multiplier, presence: true
end
