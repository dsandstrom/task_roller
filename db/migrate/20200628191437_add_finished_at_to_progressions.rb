class AddFinishedAtToProgressions < ActiveRecord::Migration[6.0]
  def change
    add_column :progressions, :finished_at, :datetime, precision: 6
  end
end
