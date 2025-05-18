class BattleLog < ApplicationRecord
  belongs_to :battleable, polymorphic: true
  validates :message, presence: true
  validates :turn, presence: true
end

