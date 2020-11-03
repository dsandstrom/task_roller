class CreateCategoryIssuesSubscriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :category_issues_subscriptions do |t|
      t.integer :category_id, null: false
      t.integer :user_id, null: false

      t.timestamps
    end
  end
end
