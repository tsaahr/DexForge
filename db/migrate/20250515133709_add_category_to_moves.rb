class AddCategoryToMoves < ActiveRecord::Migration[7.1]
  def change
    add_column :moves, :category, :integer
  end
end
