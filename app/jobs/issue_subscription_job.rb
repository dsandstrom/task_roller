class IssueSubscriptionJob < SubscriptionJob
  def perform(issue, user, send_new: false)
    super

    return unless send_new

    IssueNotifierJob.perform_later(issue, user, { event: 'new' })
  end
end
