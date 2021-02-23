class AddStatusToTasks < ActiveRecord::Migration[6.1]
  def change
    add_column :issues, :status, :string, null: false, default: 'open'
    add_column :tasks, :status, :string, null: false, default: 'open'

    add_index :issues, :status
    add_index :tasks, :status
  end
end
