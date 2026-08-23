class TaskSubscriptionJob < ApplicationJob
  queue_as :default

  attr_accessor :task, :user

  def perform(task, user)
    return unless task && user

    task.subscribe_user(user)
  end
end
