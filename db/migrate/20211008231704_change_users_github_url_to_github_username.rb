class ChangeUsersGithubUrlToGithubUsername < ActiveRecord::Migration[6.1]
  def change
    rename_column :users, :github_url, :github_username
  end
end
