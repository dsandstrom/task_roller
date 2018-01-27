class CreateRollerTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :roller_types do |t|
      t.string :name
      t.string :icon
      t.string :color
      t.string :type

      t.timestamps
    end

    add_index :roller_types, :type
    add_index :roller_types, :name
  end
end
