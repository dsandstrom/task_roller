class CreateIssueReopenings < ActiveRecord::Migration[6.0]
  def change
    create_table :issue_reopenings do |t|
      t.integer :issue_id, null: false
      t.integer :user_id, null: false

      t.timestamps
    end
  end
end
