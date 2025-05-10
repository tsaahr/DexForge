class AddIvsToUserPokemons < ActiveRecord::Migration[7.1]
  def change
    add_column :user_pokemons, :hp_iv, :integer
    add_column :user_pokemons, :attack_iv, :integer
    add_column :user_pokemons, :defense_iv, :integer
    add_column :user_pokemons, :sp_attack_iv, :integer
    add_column :user_pokemons, :sp_defense_iv, :integer
    add_column :user_pokemons, :speed_iv, :integer
  end
end
