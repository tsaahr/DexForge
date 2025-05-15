class SyncWildAndUserPokemonsStructure < ActiveRecord::Migration[7.1]
  change_table :wild_pokemons do |t|
    t.integer :hp
    t.integer :attack
    t.integer :defense
    t.integer :speed
    t.integer :sp_attack
    t.integer :sp_defense
    t.integer :hp_iv
    t.integer :attack_iv
    t.integer :defense_iv
    t.integer :sp_attack_iv
    t.integer :sp_defense_iv
    t.integer :speed_iv

    t.remove :stats
    t.remove :max_hp
  end
  change_column_default :user_pokemons, :current_moves, from: nil, to: []
end
