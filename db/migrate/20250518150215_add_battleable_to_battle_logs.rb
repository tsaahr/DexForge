class AddBattleableToBattleLogs < ActiveRecord::Migration[7.1]
  def change
    add_reference :battle_logs, :battleable, polymorphic: true, null: false
  end
end
