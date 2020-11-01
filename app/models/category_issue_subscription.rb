# frozen_string_literal: true

class CategoryIssueSubscription < CategorySubscription
  MESSAGE = 'already subscribed to category issues'
  validates :user_id, uniqueness: { scope: %i[category_id type],
                                    message: MESSAGE }
end
