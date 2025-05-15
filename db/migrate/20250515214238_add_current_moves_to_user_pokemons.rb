class AddCurrentMovesToUserPokemons < ActiveRecord::Migration[7.1]
  def change
    add_column :user_pokemons, :current_moves, :jsonb
  end
end
