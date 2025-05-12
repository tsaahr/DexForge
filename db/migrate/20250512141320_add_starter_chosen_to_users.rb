class AddStarterChosenToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :starter_chosen, :boolean
  end
end
