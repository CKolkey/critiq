class AddTeamForeignKeyToUsers < ActiveRecord::Migration[5.2]
  def change
    add_reference :teams, :user, foreign_key: true
    add_column :users, :tid, :string
  end
end
