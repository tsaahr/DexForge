class StatChangeForBattle < ActiveRecord::Migration[7.1]
  def change
    add_column :battles, :stat_stages, :jsonb, default: {}
    add_column :wild_battles, :stat_stages, :jsonb, default: {}

  end
end
