class TaskSubscriberNotifierJob < ApplicationJob
  queue_as :default

  def perform(task, subscriber, options)
    options.merge!(user: subscriber)
    notification = find_or_create_notification(task, subscriber, options)
    notification.send_email
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.debug { "IssueNotification invalid:\n#{e.inspect}" }
  end

  private

    def find_or_create_notification(task, subscriber, options)
      if options[:event] == 'status'
        notification = task.notifications.find_by(user_id: subscriber.id,
                                                  event: 'status')
      end

      if notification
        notification.update(options)
      else
        notification = task.notifications.create!(options)
      end

      notification
    end
end
