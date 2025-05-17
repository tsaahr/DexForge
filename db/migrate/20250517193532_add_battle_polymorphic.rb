class AddBattlePolymorphic < ActiveRecord::Migration[7.1]
  def up
    add_reference :battle_turns, :battleable, polymorphic: true, null: true

    execute <<-SQL.squish
      UPDATE battle_turns
      SET battleable_id = battle_id,
          battleable_type = 'Battle'
    SQL

    change_column_null :battle_turns, :battleable_id, false
    change_column_null :battle_turns, :battleable_type, false

    remove_column :battle_turns, :battle_id
  end

  def down
    add_column :battle_turns, :battle_id, :bigint, null: false

    execute <<-SQL.squish
      UPDATE battle_turns
      SET battle_id = battleable_id
      WHERE battleable_type = 'Battle'
    SQL

    remove_reference :battle_turns, :battleable, polymorphic: true
  end

end
