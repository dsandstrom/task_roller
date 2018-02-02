class AddPositionToRollerTypes < ActiveRecord::Migration[5.1]
  def change
    add_column :roller_types, :position, :integer
  end
end
