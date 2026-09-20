class CreateSearchSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :search_subscriptions do |t|
      t.boolean :active, default: true, null: false
      t.integer :user_id, null: false
      t.boolean :include_issues, default: true, null: false
      t.boolean :include_tasks, default: true, null: false
      t.string :term
      t.integer :issue_type_id
      t.integer :task_type_id
      t.string :status
      t.integer :source_user_id
      t.integer :category_id
      t.integer :project_id

      t.timestamps
    end
  end
end
