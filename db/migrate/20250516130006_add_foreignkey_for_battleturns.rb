class AddForeignkeyForBattleturns < ActiveRecord::Migration[7.1]
  def change
    add_foreign_key "battle_turns", "user_pokemons", column: "attacker_id"
    add_foreign_key "battle_turns", "user_pokemons", column: "defender_id"
  end
end
