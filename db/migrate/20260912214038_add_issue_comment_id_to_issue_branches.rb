class AddIssueCommentIdToIssueBranches < ActiveRecord::Migration[8.1]
  def change
    change_table :issue_branches, bulk: true do |t|
      t.integer :issue_comment_id
      t.integer :task_comment_id
    end
  end
end
