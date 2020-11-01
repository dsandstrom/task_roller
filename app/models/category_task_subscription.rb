# frozen_string_literal: true

class CategoryTaskSubscription < CategorySubscription
  MESSAGE = 'already subscribed to category tasks'
  validates :user_id, uniqueness: { scope: %i[category_id type],
                                    message: MESSAGE }
end
