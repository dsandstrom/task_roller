class SubscribersNotifierJob < ApplicationJob
  queue_as :default

  attr_accessor :source

  private

    def subscribers_except(ignored_user = nil)
      if ignored_user
        source.subscribers.where.not(id: ignored_user.id)
      else
        source.subscribers
      end
    end
end
