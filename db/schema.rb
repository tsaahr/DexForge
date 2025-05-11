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

ActiveRecord::Schema[7.1].define(version: 2025_05_11_133033) do
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
    t.string "moves"
    t.jsonb "sprites"
    t.index ["pokeapi_id"], name: "index_pokemons_on_pokeapi_id"
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
    t.index ["pokemon_id"], name: "index_user_pokemons_on_pokemon_id"
    t.index ["user_id"], name: "index_user_pokemons_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "user_pokemons", "pokemons"
  add_foreign_key "user_pokemons", "users"
end
