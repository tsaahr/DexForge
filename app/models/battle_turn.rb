class BattleTurn < ApplicationRecord
  belongs_to :battleable, polymorphic: true

  belongs_to :attacker, polymorphic: true
  belongs_to :defender, polymorphic: true
end

