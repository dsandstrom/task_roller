class ChangeUserIdNull < ActiveRecord::Migration[6.1]
  def change
    change_column_null :issue_closures, :user_id, true
    change_column_null :issue_comments, :user_id, true
    change_column_null :issue_reopenings, :user_id, true
    change_column_null :progressions, :user_id, true
    change_column_null :resolutions, :user_id, true
    change_column_null :reviews, :user_id, true
    change_column_null :task_closures, :user_id, true
    change_column_null :task_comments, :user_id, true
    change_column_null :task_reopenings, :user_id, true
  end
end
