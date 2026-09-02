class AddPriorityLevelToTasks < ActiveRecord::Migration[8.1]
  def change
    add_column :tasks, :priority_level, :integer, null: false, default: 4
    add_index :tasks, :priority_level
  end
end
