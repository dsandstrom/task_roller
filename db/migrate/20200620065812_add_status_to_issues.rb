class AddStatusToIssues < ActiveRecord::Migration[6.0]
  def change
    add_column :issues, :status, :string
    add_column :tasks, :status, :string
  end
end
