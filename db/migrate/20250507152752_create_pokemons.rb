class CreatePokemons < ActiveRecord::Migration[7.1]
  def change
    create_table :pokemons do |t|
      t.string :name
      t.string :image_url
      t.integer :pokeapi_id
      t.jsonb :stats, default: []

      t.timestamps
    end
    add_index :pokemons, :pokeapi_id
  end
end
