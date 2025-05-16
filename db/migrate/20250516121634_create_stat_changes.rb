class CreateStatChanges < ActiveRecord::Migration[7.1]
  def change
    create_table "stat_changes" do |t|
      t.references "move", null: false, foreign_key: true
      t.string "stat_name"
      t.integer "change"
      t.timestamps
    end
    
  end
end
