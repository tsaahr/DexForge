class CreateBattles < ActiveRecord::Migration[7.1]
  def change
    create_table :battles do |t|
      t.references :user_pokemon_1, null: false, foreign_key: { to_table: :user_pokemons }
      t.references :user_pokemon_2, null: false, foreign_key: { to_table: :user_pokemons }
      t.integer :winner_id
      t.integer :turn
      t.string :status

      t.timestamps
    end
  end
end
