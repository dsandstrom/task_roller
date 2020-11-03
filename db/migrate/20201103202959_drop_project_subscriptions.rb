class DropProjectSubscriptions < ActiveRecord::Migration[6.0]
  def change
    drop_table :project_subscriptions do |t|
      t.integer :project_id, null: false
      t.integer :user_id, null: false
      t.string :type, null: false

      t.timestamps
    end
  end
end
