class AddGithubRepoIdToIssues < ActiveRecord::Migration[6.1]
  def change
    add_column :issues, :github_repo_id, :integer
  end
end
