class AddCommitMessagePartToRepoCallouts < ActiveRecord::Migration[6.1]
  def change
    add_column :repo_callouts, :commit_message_part, :string, null: false
  end
end
