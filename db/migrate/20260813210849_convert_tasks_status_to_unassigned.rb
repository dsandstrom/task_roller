class ConvertTasksStatusToUnassigned < ActiveRecord::Migration[8.1]
  def up
    Task.where(status: 'open').update_all(status: 'unassigned')
  end

  def down
    Task.where(status: 'unassigned').update_all(status: 'open')
  end
end
