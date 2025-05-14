class RemoveHpFromWildPokemons < ActiveRecord::Migration[7.1]
  def change
    remove_column :wild_pokemons, :hp, :integer
  end
end
