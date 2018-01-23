class CreateProjects < ActiveRecord::Migration[5.1]
  def change
    create_table :projects do |t|
      t.string :name
      t.boolean :visible, default: true
      t.boolean :internal, default: false
      t.integer :category_id

      t.timestamps
    end

    add_index :projects, :category_id
    add_index :projects, :visible
    add_index :projects, :internal
  end
end
