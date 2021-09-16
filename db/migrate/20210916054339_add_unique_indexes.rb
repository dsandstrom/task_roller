class AddUniqueIndexes < ActiveRecord::Migration[6.1]
  def change
    add_index :category_issues_subscriptions, %i[category_id user_id],
              unique: true
    add_index :category_tasks_subscriptions, %i[category_id user_id],
              unique: true
    add_index :issue_subscriptions, %i[issue_id user_id],
              unique: true
    add_index :issue_types, :name, unique: true
    add_index :projects, %i[category_id name], unique: true
    add_index :project_issues_subscriptions, %i[project_id user_id],
              unique: true
    add_index :project_tasks_subscriptions, %i[project_id user_id],
              unique: true
    add_index :task_assignees, %i[task_id assignee_id], unique: true
    add_index :task_subscriptions, %i[task_id user_id],
              unique: true
    add_index :task_types, :name, unique: true
  end
end
