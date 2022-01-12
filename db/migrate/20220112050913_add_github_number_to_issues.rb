class AddGithubNumberToIssues < ActiveRecord::Migration[6.1]
  def change
    add_column :issues, :github_number, :integer
  end
end
