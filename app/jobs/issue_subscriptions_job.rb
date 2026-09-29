class IssueSubscriptionsJob < ApplicationJob
  queue_as :default

  def perform(issue, **options)
    return unless issue

    issue.search_subscribers.each do |subscriber|
      next if subscriber == issue.user
      next if issue.issue_subscriptions.find_by(user: subscriber)

      IssueSubscriptionJob.perform_later(issue, subscriber, options)
    end
  end
end
