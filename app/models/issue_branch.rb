class IssueBranch < ApplicationRecord
  # trunk
  belongs_to :source_issue, class_name: 'Issue',
                            inverse_of: :source_issue_branches,
                            optional: true
  belongs_to :source_task, class_name: 'Task',
                           inverse_of: :source_issue_branches,
                           optional: true
  # branch issue
  belongs_to :target, class_name: 'Issue', inverse_of: :target_issue_branch
  belongs_to :user

  validate :source_issue_or_task

  private

    def source_issue_or_task
      return if !source_issue_id.nil? && source_task_id.nil?
      return if source_issue_id.nil? && !source_task_id.nil?

      errors.add(:base, 'must have source issue or task')
    end
end
