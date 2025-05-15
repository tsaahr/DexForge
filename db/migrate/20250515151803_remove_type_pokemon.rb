class RemoveTypePokemon < ActiveRecord::Migration[7.1]
  def change
    remove_column :pokemons, :types, :string, array: true, default: []
  end
end
