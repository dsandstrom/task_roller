class IssueSubscriptionJob < SubscriptionJob
  def perform(issue, user, options = {})
    super
    return unless options[:send_new]

    IssueNotifierJob.perform_later(issue, user, { event: 'new' })
  end
end
