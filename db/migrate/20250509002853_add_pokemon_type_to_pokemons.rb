class AddPokemonTypeToPokemons < ActiveRecord::Migration[7.1]
  def change
    add_column :pokemons, :pokemon_type, :string
  end
end
