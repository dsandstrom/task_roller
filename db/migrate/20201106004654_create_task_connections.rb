class CreateTaskConnections < ActiveRecord::Migration[6.0]
  def change
    create_table :task_connections do |t|
      t.integer :source_id, null: false
      t.integer :target_id, null: false
      t.string :scheme

      t.timestamps
    end
  end
end
