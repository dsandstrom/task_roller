class AddPriorityLevelToIssues < ActiveRecord::Migration[8.1]
  def change
    add_column :issues, :priority_level, :integer
    add_index :issues, :priority_level

    Issue.joins(:tasks).distinct.each do |issue|
      issue.update(
        priority_level: Task.where(issue_id: issue.id).minimum(:priority_level)
      )
    end
  end
end
