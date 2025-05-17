class AddStatusToWildBattles < ActiveRecord::Migration[7.1]
  def change
    add_column :wild_battles, :status, :string
  end
end
