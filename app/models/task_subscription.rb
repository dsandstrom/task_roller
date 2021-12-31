# frozen_string_literal: true

class TaskSubscription < ApplicationRecord
  MESSAGE = 'already subscribed to task'
  validates :user_id, uniqueness: { scope: :task_id, message: MESSAGE }

  belongs_to :user
  belongs_to :task

  delegate :heading, to: :task
end
