class AddWildPokemonIdToUserPokemons < ActiveRecord::Migration[7.1]
  def change
    add_column :user_pokemons, :wild_pokemon_id, :integer
  end
end
