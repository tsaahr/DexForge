class AddEvolvesFromToPokemons < ActiveRecord::Migration[7.0]
  def change
    add_reference :pokemons, :evolves_from, foreign_key: { to_table: :pokemons }
  end
end
