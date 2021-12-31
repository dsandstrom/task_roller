# frozen_string_literal: true

class TaskReopening < ApplicationRecord
  belongs_to :task
  belongs_to :user

  def subscribe_user
    return unless user && task

    task.subscribe_user(user)
  end
end
