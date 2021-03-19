class AddIssueCommentIdToIssueNotifications < ActiveRecord::Migration[6.1]
  def change
    add_column :issue_notifications, :issue_comment_id, :integer
  end
end
