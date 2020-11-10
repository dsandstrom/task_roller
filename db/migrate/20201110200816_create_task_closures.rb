class CreateTaskClosures < ActiveRecord::Migration[6.0]
  def change
    create_table :task_closures do |t|
      t.integer :task_id, null: false
      t.integer :user_id, null: false

      t.timestamps
    end
  end
end
