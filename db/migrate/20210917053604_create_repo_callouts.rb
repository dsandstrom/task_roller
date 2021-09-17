class CreateRepoCallouts < ActiveRecord::Migration[6.1]
  def change
    create_table :repo_callouts do |t|
      t.integer :user_id
      t.integer :task_id, null: false
      t.string :action, null: false
      t.text :commit_message, null: false
      t.string :commit_html_url
      t.string :commit_sha, null: false
      t.integer :github_commit_id

      t.timestamps
    end

    add_index :repo_callouts, :task_id
    add_index :repo_callouts, %i[task_id commit_sha], unique: true
  end
end
