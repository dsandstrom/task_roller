class DropRollerTypes < ActiveRecord::Migration[6.0]
  def change
    drop_table :roller_types do |t|
      t.string :name
      t.string :icon
      t.string :color
      t.string :type
      t.integer :position

      t.timestamps
    end
  end
end
