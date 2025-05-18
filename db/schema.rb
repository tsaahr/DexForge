# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_05_18_152522) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "battle_logs", force: :cascade do |t|
    t.text "message"
    t.integer "turn"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "battleable_type", null: false
    t.bigint "battleable_id", null: false
    t.index ["battleable_type", "battleable_id"], name: "index_battle_logs_on_battleable"
  end

  create_table "battle_turns", force: :cascade do |t|
    t.integer "damage"
    t.integer "turn_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "wild_battle_id"
    t.string "attacker_type"
    t.bigint "attacker_id"
    t.string "defender_type"
    t.bigint "defender_id"
    t.string "battleable_type", null: false
    t.bigint "battleable_id", null: false
    t.index ["attacker_type", "attacker_id"], name: "index_battle_turns_on_attacker"
    t.index ["battleable_type", "battleable_id"], name: "index_battle_turns_on_battleable"
    t.index ["defender_type", "defender_id"], name: "index_battle_turns_on_defender"
    t.index ["wild_battle_id"], name: "index_battle_turns_on_wild_battle_id"
  end

  create_table "battles", force: :cascade do |t|
    t.bigint "user_pokemon_1_id", null: false
    t.bigint "user_pokemon_2_id", null: false
    t.integer "winner_id"
    t.integer "turn"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "stat_stages", default: {}
    t.index ["user_pokemon_1_id"], name: "index_battles_on_user_pokemon_1_id"
    t.index ["user_pokemon_2_id"], name: "index_battles_on_user_pokemon_2_id"
  end

  create_table "move_status_effects", force: :cascade do |t|
    t.bigint "move_id", null: false
    t.bigint "status_effect_id", null: false
    t.float "chance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["move_id"], name: "index_move_status_effects_on_move_id"
    t.index ["status_effect_id"], name: "index_move_status_effects_on_status_effect_id"
  end

  create_table "moves", force: :cascade do |t|
    t.string "name"
    t.string "move_type"
    t.string "damage_class"
    t.integer "power"
    t.integer "accuracy"
    t.integer "pp"
    t.text "description"
    t.integer "pokeapi_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "level_learned_at"
    t.integer "category"
    t.bigint "type_id"
    t.index ["type_id"], name: "index_moves_on_type_id"
  end

  create_table "pokemon_moves", force: :cascade do |t|
    t.bigint "pokemon_id", null: false
    t.bigint "move_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "level_learned_at"
    t.index ["move_id"], name: "index_pokemon_moves_on_move_id"
    t.index ["pokemon_id"], name: "index_pokemon_moves_on_pokemon_id"
  end

  create_table "pokemon_status_effects", force: :cascade do |t|
    t.bigint "user_pokemon_id", null: false
    t.bigint "status_effect_id", null: false
    t.integer "remaining_turns"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status_effect_id"], name: "index_pokemon_status_effects_on_status_effect_id"
    t.index ["user_pokemon_id"], name: "index_pokemon_status_effects_on_user_pokemon_id"
  end

  create_table "pokemon_types", force: :cascade do |t|
    t.bigint "pokemon_id", null: false
    t.bigint "type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pokemon_id"], name: "index_pokemon_types_on_pokemon_id"
    t.index ["type_id"], name: "index_pokemon_types_on_type_id"
  end

  create_table "pokemons", force: :cascade do |t|
    t.string "name"
    t.string "image_url"
    t.integer "pokeapi_id"
    t.jsonb "stats", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "height"
    t.integer "weight"
    t.integer "base_experience"
    t.text "flavor_text"
    t.string "abilities"
    t.jsonb "sprites"
    t.integer "evolution_level"
    t.bigint "evolves_to_id"
    t.string "evolution_method"
    t.integer "stage"
    t.bigint "evolves_from_id"
    t.boolean "is_legendary"
    t.boolean "is_mythical"
    t.jsonb "moves", default: []
    t.index ["evolves_from_id"], name: "index_pokemons_on_evolves_from_id"
    t.index ["evolves_to_id"], name: "index_pokemons_on_evolves_to_id"
    t.index ["pokeapi_id"], name: "index_pokemons_on_pokeapi_id"
  end

  create_table "stat_changes", force: :cascade do |t|
    t.bigint "move_id", null: false
    t.string "stat_name"
    t.integer "change"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["move_id"], name: "index_stat_changes_on_move_id"
  end

  create_table "status_effects", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "duration"
    t.string "effect_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "type_effectivenesses", force: :cascade do |t|
    t.bigint "attacking_type_id", null: false
    t.bigint "defending_type_id", null: false
    t.float "multiplier", default: 1.0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attacking_type_id"], name: "index_type_effectivenesses_on_attacking_type_id"
    t.index ["defending_type_id"], name: "index_type_effectivenesses_on_defending_type_id"
  end

  create_table "types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_pokemons", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "pokemon_id", null: false
    t.integer "level"
    t.integer "experience"
    t.string "nickname"
    t.integer "current_hp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "hp"
    t.integer "attack"
    t.integer "defense"
    t.integer "speed"
    t.integer "sp_attack"
    t.integer "sp_defense"
    t.integer "hp_iv"
    t.integer "attack_iv"
    t.integer "defense_iv"
    t.integer "sp_attack_iv"
    t.integer "sp_defense_iv"
    t.integer "speed_iv"
    t.integer "wild_pokemon_id"
    t.jsonb "moves", default: []
    t.boolean "selected"
    t.index ["pokemon_id"], name: "index_user_pokemons_on_pokemon_id"
    t.index ["user_id"], name: "index_user_pokemons_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "encrypted_password"
    t.datetime "remember_created_at"
    t.boolean "starter_chosen"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
  end

  create_table "wild_battles", force: :cascade do |t|
    t.bigint "user_pokemon_id", null: false
    t.bigint "wild_pokemon_id", null: false
    t.string "winner_type"
    t.integer "winner_id"
    t.string "current_turn"
    t.text "battle_log"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "stat_stages", default: {}
    t.string "status"
    t.integer "turn"
    t.index ["user_pokemon_id"], name: "index_wild_battles_on_user_pokemon_id"
    t.index ["wild_pokemon_id"], name: "index_wild_battles_on_wild_pokemon_id"
  end

  create_table "wild_pokemons", force: :cascade do |t|
    t.bigint "pokemon_id", null: false
    t.integer "level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "moves", default: []
    t.integer "current_hp", null: false
    t.boolean "captured", default: false
    t.integer "hp"
    t.integer "attack"
    t.integer "defense"
    t.integer "speed"
    t.integer "sp_attack"
    t.integer "sp_defense"
    t.integer "hp_iv"
    t.integer "attack_iv"
    t.integer "defense_iv"
    t.integer "sp_attack_iv"
    t.integer "sp_defense_iv"
    t.integer "speed_iv"
    t.index ["pokemon_id"], name: "index_wild_pokemons_on_pokemon_id"
  end

  add_foreign_key "battle_turns", "wild_battles"
  add_foreign_key "battles", "user_pokemons", column: "user_pokemon_1_id"
  add_foreign_key "battles", "user_pokemons", column: "user_pokemon_2_id"
  add_foreign_key "move_status_effects", "moves"
  add_foreign_key "move_status_effects", "status_effects"
  add_foreign_key "moves", "types"
  add_foreign_key "pokemon_moves", "moves"
  add_foreign_key "pokemon_moves", "pokemons"
  add_foreign_key "pokemon_status_effects", "status_effects"
  add_foreign_key "pokemon_status_effects", "user_pokemons"
  add_foreign_key "pokemon_types", "pokemons"
  add_foreign_key "pokemon_types", "types"
  add_foreign_key "pokemons", "pokemons", column: "evolves_from_id"
  add_foreign_key "pokemons", "pokemons", column: "evolves_to_id"
  add_foreign_key "stat_changes", "moves"
  add_foreign_key "type_effectivenesses", "types", column: "attacking_type_id"
  add_foreign_key "type_effectivenesses", "types", column: "defending_type_id"
  add_foreign_key "user_pokemons", "pokemons"
  add_foreign_key "user_pokemons", "users"
  add_foreign_key "wild_battles", "user_pokemons"
  add_foreign_key "wild_battles", "wild_pokemons"
  add_foreign_key "wild_pokemons", "pokemons"
end
