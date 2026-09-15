class CreateIssueBranches < ActiveRecord::Migration[8.1]
  def change
    create_table :issue_branches do |t|
      t.integer :source_issue_id
      t.integer :source_task_id
      t.integer :target_id, null: false
      t.integer :user_id, null: false

      t.timestamps
    end
  end
end
