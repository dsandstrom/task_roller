class TaskAssigneesSubscriptionsJob < ApplicationJob
  queue_as :default

  attr_accessor :task

  def perform(task)
    return unless task

    task.assignees.each do |u|
      TaskSubscriptionJob.perform_later(task, u)
    end
  end
end
