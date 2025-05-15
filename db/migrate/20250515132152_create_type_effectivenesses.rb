class CreateTypeEffectivenesses < ActiveRecord::Migration[7.1]
  def change
    create_table :type_effectivenesses do |t|
      t.references :attacking_type, null: false, foreign_key: { to_table: :types }
      t.references :defending_type, null: false, foreign_key: { to_table: :types }
      t.float :multiplier, null: false, default: 1.0

      t.timestamps
    end
  end
end
