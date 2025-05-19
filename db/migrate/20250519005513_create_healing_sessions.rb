class CreateHealingSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :healing_sessions do |t|
      t.references :user_pokemon, null: false, foreign_key: true
      t.datetime :started_at
      t.datetime :finished_at

      t.timestamps
    end
  end
end
