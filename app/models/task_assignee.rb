# frozen_string_literal: true

class TaskAssignee < ApplicationRecord
  belongs_to :task
  belongs_to :assignee, class_name: 'User', inverse_of: :task_assignees

  validates :task_id, uniqueness: { scope: :assignee_id,
                                    message: 'already assigned to User' }
  validates :assignee, presence: true, if: :assignee_id
end
