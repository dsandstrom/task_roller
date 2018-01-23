class CreateCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :categories do |t|
      t.string :name
      t.boolean :visible, default: true
      t.boolean :internal, default: false

      t.timestamps
    end

    add_index :categories, :visible
    add_index :categories, :internal
  end
end
