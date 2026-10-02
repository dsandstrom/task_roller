class SubscribersNotifierJob < ApplicationJob
  queue_as :default

  attr_accessor :source

  private

    def subscribers_except(ignored_user = nil)
      subscribers = source.active_subscribers
      return subscribers unless ignored_user

      subscribers.where.not(id: ignored_user.id)
    end
end
