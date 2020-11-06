class DropRollerComments < ActiveRecord::Migration[6.0]
  def change
    drop_table :roller_comments do |t|
      t.string :type
      t.integer :roller_id
      t.integer :user_id
      t.text :body

      t.timestamps
    end
  end
end
