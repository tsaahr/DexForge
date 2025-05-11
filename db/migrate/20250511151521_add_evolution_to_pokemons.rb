class AddEvolutionToPokemons < ActiveRecord::Migration[7.1]
  def change
    add_column :pokemons, :evolution_level, :integer
    add_reference :pokemons, :evolves_to, foreign_key: { to_table: :pokemons }
  end
end
