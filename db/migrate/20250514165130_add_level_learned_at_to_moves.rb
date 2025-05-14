class AddLevelLearnedAtToMoves < ActiveRecord::Migration[7.1]
  def change
    add_column :moves, :level_learned_at, :integer
  end
end
