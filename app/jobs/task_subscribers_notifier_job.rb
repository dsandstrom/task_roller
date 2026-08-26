class TaskSubscribersNotifierJob < SubscribersNotifierJob
  def perform(task, options)
    self.source = task

    subscribers_except(options.delete(:current_user)).each do |subscriber|
      TaskNotifierJob.perform_later(task, subscriber, options)
    end
  end
end
