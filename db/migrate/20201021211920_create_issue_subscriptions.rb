class CreateIssueSubscriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :issue_subscriptions do |t|
      t.integer :user_id, null: false
      t.integer :issue_id, null: false

      t.timestamps
    end
  end
end
