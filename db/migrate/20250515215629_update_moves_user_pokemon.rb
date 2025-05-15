class UpdateMovesUserPokemon < ActiveRecord::Migration[7.0]
  def change
    rename_column :user_pokemons, :current_moves, :moves
  end
end
