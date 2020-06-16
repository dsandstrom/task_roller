class AddClosedIndexToIssuesAndTasks < ActiveRecord::Migration[6.0]
  def change
    add_index :issues, :closed
    add_index :tasks, :closed
  end
end
