class TaskAssigneesSubscriptionsJob < ApplicationJob
  queue_as :default

  attr_accessor :task

  def perform(task, **options)
    return unless task

    task.assignees.each do |user|
      next if task.task_subscriptions.find_by(user: user)

      TaskSubscriptionJob.perform_later(task, user, options)
    end
  end
end
