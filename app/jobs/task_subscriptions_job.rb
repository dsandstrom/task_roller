class TaskSubscriptionsJob < ApplicationJob
  queue_as :default

  def perform(task)
    return unless task

    subscribers = task.category.task_subscribers |
                  task.project.task_subscribers

    subscribers.each do |u|
      # TODO: send 'new' notification
      TaskSubscriptionJob.perform_later(task, u)
    end
  end
end
