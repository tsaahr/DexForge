class AddEvolutionMethodToPokemons < ActiveRecord::Migration[7.1]
  def change
    add_column :pokemons, :evolution_method, :string
  end
end
