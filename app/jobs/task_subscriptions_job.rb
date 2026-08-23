class TaskSubscriptionsJob < ApplicationJob
  queue_as :default

  attr_accessor :task

  def perform(task)
    return unless task

    subscribers = [task.user] |
                  task.category.task_subscribers |
                  task.project.task_subscribers

    subscribers.each do |u|
      TaskSubscriptionJob.perform_later(task, u)
    end
  end
end
