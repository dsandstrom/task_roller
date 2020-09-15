class CreateRollerConnections < ActiveRecord::Migration[6.0]
  def change
    create_table :roller_connections do |t|
      t.string :type, null: false
      t.integer :source_id, null: false
      t.integer :target_id, null: false
      t.string :scheme

      t.timestamps
    end
  end
end
