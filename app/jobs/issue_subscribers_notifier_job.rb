class IssueSubscribersNotifierJob < SubscribersNotifierJob
  def perform(issue, options)
    self.source = issue

    subscribers_except(options.delete(:current_user)).each do |subscriber|
      IssueNotifierJob.perform_later(issue, subscriber, options)
    end
  end
end
