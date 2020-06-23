class RemoveStatusFromTasks < ActiveRecord::Migration[6.0]
  def change
    remove_column :tasks, :status, :string
    remove_column :issues, :status, :string
  end
end
