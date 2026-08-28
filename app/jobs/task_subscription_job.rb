class TaskSubscriptionJob < SubscriptionJob
  def perform(task, user, options = {})
    super
    return unless options[:send_new]

    TaskNotifierJob.perform_later(task, user, { event: 'new' })
  end
end
