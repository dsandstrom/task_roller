class SubscriptionJob < ApplicationJob
  queue_as :default

  def perform(source, user, **_options)
    return unless source && user

    source.subscribe_user(user)
  end
end
