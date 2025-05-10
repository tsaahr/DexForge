class CreateMoves < ActiveRecord::Migration[7.1]
  def change
    create_table :moves do |t|
      t.string :name
      t.string :move_type
      t.string :damage_class
      t.integer :power
      t.integer :accuracy
      t.integer :pp
      t.text :description
      t.integer :pokeapi_id

      t.timestamps
    end
  end
end
