class ChangeStatusFromTasks < ActiveRecord::Migration[6.1]
  def change
    change_column_default :tasks, :status, nil
    change_column_null :tasks, :status, true
  end
end
