class TaskSubscriptionsJob < ApplicationJob
  queue_as :default

  def perform(task, **options)
    return unless task

    subscribers = task.category.task_subscribers |
                  task.project.task_subscribers

    subscribers.each do |u|
      TaskSubscriptionJob.perform_later(task, u, options)
    end
  end
end
