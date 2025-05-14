class AddDetailsToWildPokemons < ActiveRecord::Migration[7.1]
  def change
    add_column :wild_pokemons, :max_hp, :integer, null: false
    add_column :wild_pokemons, :current_hp, :integer, null: false
    add_column :wild_pokemons, :captured, :boolean, default: false
  end
end
