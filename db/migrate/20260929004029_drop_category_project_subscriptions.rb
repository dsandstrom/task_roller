class DropCategoryProjectSubscriptions < ActiveRecord::Migration[8.1]
  def change
    remove_index :category_issues_subscriptions, %i[category_id user_id],
                 unique: true
    remove_index :category_tasks_subscriptions, %i[category_id user_id],
                 unique: true
    remove_index :project_issues_subscriptions, %i[project_id user_id],
                 unique: true
    remove_index :project_tasks_subscriptions, %i[project_id user_id],
                 unique: true

    drop_table :category_issues_subscriptions do
      t.integer :category_id, null: false
      t.integer :user_id, null: false
      t.timestamps
    end

    drop_table :category_tasks_subscriptions do
      t.integer :category_id, null: false
      t.integer :user_id, null: false
      t.timestamps
    end

    drop_table :project_issues_subscriptions do
      t.integer :project_id, null: false
      t.integer :user_id, null: false
      t.timestamps
    end

    drop_table :project_tasks_subscriptions do
      t.integer :project_id, null: false
      t.integer :user_id, null: false
      t.timestamps
    end
  end
end
