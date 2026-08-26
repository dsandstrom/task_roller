class NotifierJob < ApplicationJob
  queue_as :default

  def perform(source, subscriber, options)
    options.merge!(user: subscriber)
    notification = find_or_create_notification(source, subscriber, options)
    notification.send_email
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.debug { "Notification invalid:\n#{e.inspect}" }
  end

  private

    def find_or_create_notification(source, subscriber, options)
      if options[:event] == 'status'
        notification = source.notifications.find_by(user_id: subscriber.id,
                                                    event: 'status')
      end

      if notification
        notification.update(options)
      else
        notification = source.notifications.create!(options)
      end

      notification
    end
end
