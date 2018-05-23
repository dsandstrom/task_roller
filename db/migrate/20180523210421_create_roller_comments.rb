class CreateRollerComments < ActiveRecord::Migration[5.1]
  def change
    create_table :roller_comments do |t|
      t.string :type
      t.integer :roller_id
      t.integer :user_id
      t.text :body

      t.timestamps
    end
  end
end
