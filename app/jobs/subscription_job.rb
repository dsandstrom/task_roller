class SubscriptionJob < ApplicationJob
  queue_as :default

  def perform(source, user, options = {})
    return unless source && user

    options.delete(:current_user)

    source.subscribe_user(user)
  end
end
