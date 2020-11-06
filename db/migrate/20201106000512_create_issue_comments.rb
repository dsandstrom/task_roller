class CreateIssueComments < ActiveRecord::Migration[6.0]
  def change
    create_table :issue_comments do |t|
      t.integer :issue_id, null: false
      t.integer :user_id, null: false
      t.text :body

      t.timestamps
    end
  end
end
