class CreateWildBattles < ActiveRecord::Migration[7.1]
  def change
    create_table :wild_battles do |t|
      t.references :user_pokemon, null: false, foreign_key: true
      t.references :wild_pokemon, null: false, foreign_key: true
      t.string :winner_type
      t.integer :winner_id
      t.string :current_turn
      t.text :battle_log

      t.timestamps
    end
  end
end
