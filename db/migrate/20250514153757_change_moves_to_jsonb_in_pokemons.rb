class ChangeMovesToJsonbInPokemons < ActiveRecord::Migration[7.1]
  def change
    remove_column :pokemons, :moves, :string
    add_column :pokemons, :moves, :jsonb, default: []
  end
end
