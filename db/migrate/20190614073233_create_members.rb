class CreateMembers < ActiveRecord::Migration[5.2]
  def change
    create_table :members do |t|
      t.string :uid
      t.string :first_name, default: ""
      t.string :last_name, default: ""
      t.references :team, foreign_key: true
      t.timestamps
    end
  end
end
