class AddGithubIdToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :github_id, :integer
    add_column :users, :github_url, :string

    add_index :users, :github_id, unique: true
  end
end
