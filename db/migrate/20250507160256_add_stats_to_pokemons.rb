class AddStatsToPokemons < ActiveRecord::Migration[7.1]
  def change
    add_column :pokemons, :stats, :text
  end
end
