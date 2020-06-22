class CreateProgressions < ActiveRecord::Migration[6.0]
  def change
    create_table :progressions do |t|
      t.integer :task_id, null: false
      t.integer :user_id, null: false
      t.boolean :finished, default: false, null: false

      t.timestamps
    end
  end
end
