class BattleTurn < ApplicationRecord
  belongs_to :battle
  belongs_to :attacker, class_name: 'UserPokemon'
  belongs_to :defender, class_name: 'UserPokemon'

end
