class CreateChoices < ActiveRecord::Migration[5.2]
  def change
    create_table :choices do |t|
      t.references :question, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
