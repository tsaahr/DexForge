class CreateBattleTurns < ActiveRecord::Migration[7.1]
  def change
    create_table :battle_turns do |t|
      t.references :battle, null: false, foreign_key: true
      t.integer :attacker_id
      t.integer :defender_id
      t.integer :damage
      t.integer :turn_number

      t.timestamps
    end
  end
end
