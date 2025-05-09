class ChangePokemonTypeToTypes < ActiveRecord::Migration[6.1]
  def change
    remove_column :pokemons, :pokemon_type, :string
    add_column :pokemons, :types, :string, array: true, default: []
  end
end
