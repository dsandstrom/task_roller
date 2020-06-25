# frozen_string_literal: true

class TaskAssignee < ApplicationRecord
  belongs_to :task
  belongs_to :assignee, class_name: 'User', inverse_of: :task_assignees

  validates :assignee_id, uniqueness: { scope: :task_id }
  validates :assignee, presence: true
end
