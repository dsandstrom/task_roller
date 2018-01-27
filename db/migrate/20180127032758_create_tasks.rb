class CreateTasks < ActiveRecord::Migration[5.1]
  def change
    create_table :tasks do |t|
      t.string :summary
      t.text :description
      t.integer :task_type_id
      t.integer :issue_id
      t.integer :user_id
      t.integer :project_id

      t.timestamps
    end

    add_index :tasks, :task_type_id
    add_index :tasks, :issue_id
    add_index :tasks, :user_id
    add_index :tasks, :project_id
  end
end
