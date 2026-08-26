class TaskSubscribersNotifierJob < ApplicationJob
  queue_as :default

  attr_accessor :task

  def perform(task, options)
    self.task = task

    current_user = options.delete(:current_user)
    subscribers_except(current_user).each do |subscriber|
      TaskNotifierJob.perform_later(task, subscriber, options)
    end
  end

  private

    def subscribers_except(ignored_user = nil)
      if ignored_user
        task.subscribers.where.not(id: ignored_user.id)
      else
        task.subscribers
      end
    end
end
