class AddStatsToUserPokemons < ActiveRecord::Migration[7.1]
  def change
    add_column :user_pokemons, :hp, :integer
    add_column :user_pokemons, :attack, :integer
    add_column :user_pokemons, :defense, :integer
    add_column :user_pokemons, :speed, :integer
    add_column :user_pokemons, :sp_attack, :integer
    add_column :user_pokemons, :sp_defense, :integer
  end
end
