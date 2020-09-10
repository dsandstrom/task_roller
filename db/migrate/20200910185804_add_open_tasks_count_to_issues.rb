class AddOpenTasksCountToIssues < ActiveRecord::Migration[6.0]
  def change
    add_column :issues, :tasks_count, :integer, null: false, default: 0
    add_column :issues, :open_tasks_count, :integer, null: false, default: 0
  end
end
