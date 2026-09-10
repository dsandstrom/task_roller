class IssueNotificationsRemovalJob < ApplicationJob
  queue_as :low_priority

  def perform(issue, user)
    IssueNotification.where(issue: issue, user: user).destroy_all
  end
end
