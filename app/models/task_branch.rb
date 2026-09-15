class TaskBranch < ApplicationRecord
  # trunk
  belongs_to :source_issue, class_name: 'Issue',
                            inverse_of: :source_task_branches,
                            optional: true
  belongs_to :source_task, class_name: 'Task',
                           inverse_of: :source_task_branches,
                           optional: true
  # branch task
  belongs_to :target, class_name: 'Task', inverse_of: :target_task_branch
  belongs_to :user
  belongs_to :issue_comment, class_name: 'IssueComment', optional: true,
                             inverse_of: :task_branches
  belongs_to :task_comment, class_name: 'TaskComment', optional: true,
                            inverse_of: :task_branches

  validate :source_issue_or_task

  def new_target_attrs
    attrs =
      if source_issue
        new_target_attrs_from_issue
      elsif source_task
        new_target_attrs_from_task
      end
    return {} unless attrs

    attrs[:description] += "\n\n---\n"
    attrs
  end

  private

    def source_issue_or_task
      return if !source_issue_id.nil? && source_task_id.nil?
      return if source_issue_id.nil? && !source_task_id.nil?

      errors.add(:base, 'must have source issue or task')
    end

    def new_target_attrs_from_issue
      { summary: new_target_summary(source_issue),
        description: new_target_description(source_issue, issue_comment) }
    end

    def new_target_attrs_from_task
      { summary: new_target_summary(source_task),
        description: new_target_description(source_task, task_comment) }
    end

    def new_target_summary(source)
      "#{source.summary} (Copied from #{source.class}##{source.id})"
    end

    def new_target_description(source, comment)
      if comment
        "(Copied from comment by #{comment.user.name} in " \
          "#{source.class}##{source.id})\n\n---\n\n#{comment.body}"
      else
        "(Copied from #{source.class}##{source.id})\n\n---\n\n" \
          "#{source.description}"
      end
    end
end
