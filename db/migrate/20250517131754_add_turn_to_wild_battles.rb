class AddTurnToWildBattles < ActiveRecord::Migration[7.1]
  def change
    add_column :wild_battles, :turn, :integer
  end
end
