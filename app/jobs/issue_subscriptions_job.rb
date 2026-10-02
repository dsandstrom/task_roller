class IssueSubscriptionsJob < ApplicationJob
  queue_as :default

  def perform(issue, **options)
    return unless issue

    issue.search_subscribers.not_subscribed_to_issue(issue).each do |subscriber|
      next if subscriber == issue.user

      IssueSubscriptionJob.perform_later(issue, subscriber, options)
    end
  end
end
