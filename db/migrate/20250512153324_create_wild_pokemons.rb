class CreateWildPokemons < ActiveRecord::Migration[7.1]
  def change
    create_table :wild_pokemons do |t|
      t.references :pokemon, null: false, foreign_key: true
      t.integer :level
      t.integer :hp

      t.timestamps
    end
  end
end
