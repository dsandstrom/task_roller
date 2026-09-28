class TaskSubscriptionsJob < ApplicationJob
  queue_as :default

  def perform(task, **options)
    return unless task

    subscribers = task.category.task_subscribers |
                  task.project.task_subscribers |
                  task.search_subscribers

    subscribers.each do |subscriber|
      next if subscriber == task.user

      TaskSubscriptionJob.perform_later(task, subscriber, options)
    end
  end
end
