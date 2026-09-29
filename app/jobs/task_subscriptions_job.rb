class TaskSubscriptionsJob < ApplicationJob
  queue_as :default

  def perform(task, **options)
    return unless task

    task.search_subscribers.each do |subscriber|
      next if subscriber == task.user

      TaskSubscriptionJob.perform_later(task, subscriber, options)
    end
  end
end
