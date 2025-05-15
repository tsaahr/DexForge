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

ActiveRecord::Schema[7.1].define(version: 2025_05_15_133709) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.string "types", default: [], array: true
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

  create_table "wild_pokemons", force: :cascade do |t|
    t.bigint "pokemon_id", null: false
    t.integer "level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "moves", default: []
    t.jsonb "stats", default: {}
    t.integer "max_hp", null: false
    t.integer "current_hp", null: false
    t.boolean "captured", default: false
    t.index ["pokemon_id"], name: "index_wild_pokemons_on_pokemon_id"
  end

  add_foreign_key "pokemon_moves", "moves"
  add_foreign_key "pokemon_moves", "pokemons"
  add_foreign_key "pokemon_types", "pokemons"
  add_foreign_key "pokemon_types", "types"
  add_foreign_key "pokemons", "pokemons", column: "evolves_from_id"
  add_foreign_key "pokemons", "pokemons", column: "evolves_to_id"
  add_foreign_key "type_effectivenesses", "types", column: "attacking_type_id"
  add_foreign_key "type_effectivenesses", "types", column: "defending_type_id"
  add_foreign_key "user_pokemons", "pokemons"
  add_foreign_key "user_pokemons", "users"
  add_foreign_key "wild_pokemons", "pokemons"
end
