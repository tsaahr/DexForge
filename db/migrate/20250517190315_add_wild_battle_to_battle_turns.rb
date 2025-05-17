class AddWildBattleToBattleTurns < ActiveRecord::Migration[7.1]
  def change
    add_reference :battle_turns, :wild_battle, null: true, foreign_key: true
  end
end
