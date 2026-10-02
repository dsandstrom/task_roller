class TaskSubscriptionJob < SubscriptionJob
  def perform(task, user, options = {})
    super

    TaskNotifierJob.perform_later(task, user, options)
  end
end
