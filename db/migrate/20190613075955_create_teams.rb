class CreateTeams < ActiveRecord::Migration[5.2]
  def change
    create_table :teams do |t|
      t.string :team_id
      t.string :name
      t.boolean :active, default: true
      t.string :domain
      t.string :token
      t.string :bot_user_id
      t.string :bot_access_token
      t.string :activated_user_id
      t.string :activated_user_access_token
      t.timestamps
    end
  end
end
