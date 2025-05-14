class AddLevelLearnedAtToPokemonMoves < ActiveRecord::Migration[7.1]
  def change
    add_column :pokemon_moves, :level_learned_at, :integer
  end
end
