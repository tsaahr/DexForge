class RemoveBattleFromBattleLogs < ActiveRecord::Migration[6.1]
  def change
    remove_index :battle_logs, name: "index_battle_logs_on_battle"
    remove_column :battle_logs, :battle_type, :string
    remove_column :battle_logs, :battle_id, :bigint
  end
end
