class CreateTaskSubscriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :task_subscriptions do |t|
      t.integer :user_id, null: false
      t.integer :task_id, null: false

      t.timestamps
    end
  end
end
