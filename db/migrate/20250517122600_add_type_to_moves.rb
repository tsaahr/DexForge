class AddTypeToMoves < ActiveRecord::Migration[7.1]
  def change
    add_reference :moves, :type, foreign_key: true
  end
end
