# frozen_string_literal: true

# TODO: preload project, category, user

class SearchResult < ApplicationRecord
  self.primary_key = :id

  belongs_to :user
  belongs_to :project
  delegate :category, to: :project
  belongs_to :issue
  # TODO: if issue
  belongs_to :task_type, foreign_key: :type_id
  # TODO: if task
  belongs_to :issue_type, foreign_key: :type_id
  has_many :task_assignees, foreign_key: :task_id
  has_many :assignees, through: :task_assignees

  # INSTANCE

  def issue?
    class_name == 'Issue'
  end

  def task?
    class_name == 'Task'
  end

  def heading
    @heading ||=
      ("#{class_name} \##{id}: #{short_summary}" if id && summary.present?)
  end

  def short_summary
    @short_summary ||= summary&.truncate(70)
  end

  def status
    # TODO: hardcode status in issues/tasks, and update with callbacks
  end
end
