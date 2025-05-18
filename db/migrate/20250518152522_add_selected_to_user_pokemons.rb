class AddSelectedToUserPokemons < ActiveRecord::Migration[7.1]
  def change
    add_column :user_pokemons, :selected, :boolean
  end
end
