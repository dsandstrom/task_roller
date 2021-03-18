class ChangeStatusFromIssues < ActiveRecord::Migration[6.1]
  def change
    change_column_default :issues, :status, nil
    change_column_null :issues, :status, true
  end
end
