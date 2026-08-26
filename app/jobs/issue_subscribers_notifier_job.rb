class IssueSubscribersNotifierJob < ApplicationJob
  queue_as :default

  attr_accessor :issue

  def perform(issue, options)
    self.issue = issue

    current_user = options.delete(:current_user)
    subscribers_except(current_user).each do |subscriber|
      IssueNotifierJob.perform_later(issue, subscriber, options)
    end
  end

  private

    def subscribers_except(ignored_user = nil)
      if ignored_user
        issue.subscribers.where.not(id: ignored_user.id)
      else
        issue.subscribers
      end
    end
end
