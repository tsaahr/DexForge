class CreateStatusEffects < ActiveRecord::Migration[7.1]
  def change
    create_table "status_effects" do |t|
      t.string "name"
      t.text "description"
      t.integer "duration"
      t.string "effect_type"
      t.timestamps
    end    
  end
end
