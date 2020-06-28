class AddOpenedAtToTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :issues, :opened_at, :datetime, precision: 6
    add_column :tasks, :opened_at, :datetime, precision: 6
  end
end
