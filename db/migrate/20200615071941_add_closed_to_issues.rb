class AddClosedToIssues < ActiveRecord::Migration[6.0]
  def change
    add_column :issues, :closed, :boolean, null: false, default: false
    add_column :tasks, :closed, :boolean, null: false, default: false

    Issue.update_all closed: false
    Task.update_all closed: false
  end
end
