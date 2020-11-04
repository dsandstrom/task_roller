class CreateTaskTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :task_types do |t|
      t.string :name, null: false
      t.string :icon, null: false
      t.string :color, null: false
      t.integer :position

      t.timestamps
    end
  end
end
