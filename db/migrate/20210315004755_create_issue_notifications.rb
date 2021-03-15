class CreateIssueNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :issue_notifications do |t|
      t.integer :issue_id, null: false
      t.integer :user_id, null: false
      t.string :event, null: false
      t.string :details

      t.timestamps
    end

    add_index :issue_notifications, :user_id
  end
end
