class AddGithubUserIdToIssues < ActiveRecord::Migration[6.1]
  def change
    add_column :issues, :github_user_id, :integer
  end
end
