class DropCategorySubscriptions < ActiveRecord::Migration[6.0]
  def change
    drop_table :category_subscriptions do |t|
      t.integer :category_id, null: false
      t.integer :user_id, null: false
      t.string :type, null: false

      t.timestamps
    end
  rescue PG::UndefinedTable
  end
end
