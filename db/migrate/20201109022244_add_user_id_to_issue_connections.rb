class AddUserIdToIssueConnections < ActiveRecord::Migration[6.0]
  def change
    add_column :issue_connections, :user_id, :integer
    add_column :task_connections, :user_id, :integer
  end
end
