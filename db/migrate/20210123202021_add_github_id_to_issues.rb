class AddGithubIdToIssues < ActiveRecord::Migration[6.1]
  def change
    add_column :issues, :github_id, :integer
    add_column :issues, :github_url, :string

    add_index :issues, :github_id, unique: true
  end
end
