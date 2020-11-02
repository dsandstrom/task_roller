# frozen_string_literal: true

class ProjectTaskSubscription < ProjectSubscription
  MESSAGE = 'already subscribed to project tasks'
  validates :user_id, uniqueness: { scope: %i[project_id type],
                                    message: MESSAGE }
end
