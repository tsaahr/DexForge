class CreateBattleLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :battle_logs do |t|
      t.text :message
      t.integer :turn
      t.references :battle, polymorphic: true, null: false
      t.timestamps
    end    
  end
end
