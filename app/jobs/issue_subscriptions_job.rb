class IssueSubscriptionsJob < ApplicationJob
  queue_as :default

  attr_accessor :issue

  def perform(issue)
    return unless issue

    subscribers = [issue.user] |
                  issue.category.issue_subscribers |
                  issue.project.issue_subscribers

    subscribers.each do |u|
      IssueSubscriptionJob.perform_later(issue, u)
    end
  end
end
