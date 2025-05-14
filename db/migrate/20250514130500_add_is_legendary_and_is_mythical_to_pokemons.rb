class AddIsLegendaryAndIsMythicalToPokemons < ActiveRecord::Migration[7.1]
  def change
    add_column :pokemons, :is_legendary, :boolean
    add_column :pokemons, :is_mythical, :boolean
  end
end
