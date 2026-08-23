class IssueSubscriptionJob < ApplicationJob
  queue_as :default

  attr_accessor :issue, :user

  def perform(issue, user)
    return unless issue && user

    issue.subscribe_user(user)
  end
end
