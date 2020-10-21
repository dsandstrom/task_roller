# frozen_string_literal: true

class TaskSubscription < ApplicationRecord
  validates :user_id, presence: true
  validates :task_id, presence: true

  belongs_to :user, class_name: 'User'
  belongs_to :task, class_name: 'Task'
end
