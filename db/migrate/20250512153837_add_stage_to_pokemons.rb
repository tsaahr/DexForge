class AddStageToPokemons < ActiveRecord::Migration[7.1]
  def change
    add_column :pokemons, :stage, :integer
  end
end
