class CreateTaskBranches < ActiveRecord::Migration[8.1]
  def change
    create_table :task_branches do |t|
      t.integer :source_issue_id
      t.integer :source_task_id
      t.integer :issue_comment_id
      t.integer :task_comment_id
      t.integer :target_id
      t.integer :user_id

      t.timestamps
    end
  end
end
