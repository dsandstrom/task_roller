class TaskSubscriptionJob < SubscriptionJob
  def perform(task, user, send_new: false)
    super
    return unless send_new

    TaskNotifierJob.perform_later(task, user, { event: 'new' })
  end
end
