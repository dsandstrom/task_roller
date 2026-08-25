class IssueSubscriberNotifierJob < ApplicationJob
  queue_as :default

  def perform(issue, subscriber, options)
    options.merge!(user: subscriber)
    notification = find_or_create_notification(issue, subscriber, options)

    notification.send_email
  end

  private

    def find_or_create_notification(issue, subscriber, options)
      if options[:event] == 'status'
        notification = issue.notifications.find_by(user_id: subscriber.id,
                                                   event: 'status')
      end

      if notification
        notification.update(options)
      else
        notification = issue.notifications.create!(options)
      end

      notification
    end
end
