class ChangeBattleTurnToPolymorphic < ActiveRecord::Migration[7.1]
  def change
    remove_reference :battle_turns, :attacker, index: true, foreign_key: false
    remove_reference :battle_turns, :defender, index: true, foreign_key: false
  
    add_reference :battle_turns, :attacker, polymorphic: true, index: true
    add_reference :battle_turns, :defender, polymorphic: true, index: true
  end
end
