class IssueSubscriptionsJob < ApplicationJob
  queue_as :default

  def perform(issue, options = {})
    return unless issue

    subscribers = issue.category.issue_subscribers |
                  issue.project.issue_subscribers

    subscribers.each do |u|
      IssueSubscriptionJob.perform_later(issue, u, options)
    end
  end
end
