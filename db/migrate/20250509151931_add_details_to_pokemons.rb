class AddDetailsToPokemons < ActiveRecord::Migration[7.1]
  def change
    add_column :pokemons, :height, :integer
    add_column :pokemons, :weight, :integer
    add_column :pokemons, :base_experience, :integer
    add_column :pokemons, :flavor_text, :text
    add_column :pokemons, :abilities, :string
    add_column :pokemons, :moves, :string
    add_column :pokemons, :sprites, :jsonb
  end
end
