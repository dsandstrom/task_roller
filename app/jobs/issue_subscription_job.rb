class IssueSubscriptionJob < SubscriptionJob
  def perform(issue, user, options = {})
    super

    IssueNotifierJob.perform_later(issue, user, options)
  end
end
