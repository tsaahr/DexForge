class MoveStatusEffect < ApplicationRecord
  belongs_to :move
  belongs_to :status_effect
end
