class CreateReviews < ActiveRecord::Migration[6.0]
  def change
    create_table :reviews do |t|
      t.integer :task_id, null: false
      t.integer :user_id, null: false
      t.boolean :approved, default: nil

      t.timestamps
    end
  end
end
