class IssueSubscriptionsJob < ApplicationJob
  queue_as :default

  def perform(issue, **options)
    return unless issue

    subscribers = issue.category.issue_subscribers |
                  issue.project.issue_subscribers |
                  issue.search_subscribers

    subscribers.each do |subscriber|
      next if subscriber == issue.user

      IssueSubscriptionJob.perform_later(issue, subscriber, options)
    end
  end
end
