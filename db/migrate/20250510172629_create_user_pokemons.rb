class CreateUserPokemons < ActiveRecord::Migration[7.1]
  def change
    create_table :user_pokemons do |t|
      t.references :user, null: false, foreign_key: true
      t.references :pokemon, null: false, foreign_key: true
      t.integer :level
      t.integer :experience
      t.string :nickname
      t.integer :current_hp

      t.timestamps
    end
  end
end
