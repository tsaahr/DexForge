class CreateMoveStatusEffects < ActiveRecord::Migration[7.1]
  def change
    create_table :move_status_effects do |t|
      t.references :move, null: false, foreign_key: true
      t.references :status_effect, null: false, foreign_key: true
      t.float :chance

      t.timestamps
    end
  end
end
