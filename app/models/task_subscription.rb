# frozen_string_literal: true

class TaskSubscription < ApplicationRecord
  MESSAGE = 'already subscribed to task'
  validates :user_id, presence: true,
                      uniqueness: { scope: :task_id, message: MESSAGE }
  validates :task_id, presence: true

  belongs_to :user
  belongs_to :task

  delegate :heading, to: :task
end
