class CreatePokemonStatusEffects < ActiveRecord::Migration[7.1]
  def change
    create_table :pokemon_status_effects do |t|
      t.references :user_pokemon, null: false, foreign_key: true
      t.references :status_effect, null: false, foreign_key: true
      t.integer :remaining_turns

      t.timestamps
    end
  end
end
