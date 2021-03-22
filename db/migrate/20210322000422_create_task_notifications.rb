class CreateTaskNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :task_notifications do |t|
      t.integer :task_id, null: false
      t.integer :user_id, null: false
      t.integer :task_comment_id
      t.string :event, null: false
      t.string :details

      t.timestamps
    end

    add_index :task_notifications, :user_id
  end
end
