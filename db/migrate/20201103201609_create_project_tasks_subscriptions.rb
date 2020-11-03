class CreateProjectTasksSubscriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :project_tasks_subscriptions do |t|
      t.integer :project_id, null: false
      t.integer :user_id, null: false

      t.timestamps
    end
  end
end
