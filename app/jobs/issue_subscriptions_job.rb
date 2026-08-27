class IssueSubscriptionsJob < ApplicationJob
  queue_as :default

  def perform(issue)
    return unless issue

    subscribers = issue.category.issue_subscribers |
                  issue.project.issue_subscribers

    subscribers.each do |u|
      # TODO: send 'new' notification
      IssueSubscriptionJob.perform_later(issue, u)
    end
  end
end
