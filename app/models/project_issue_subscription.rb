# frozen_string_literal: true

class ProjectIssueSubscription < ProjectSubscription
  MESSAGE = 'already subscribed to project issues'
  validates :user_id, uniqueness: { scope: %i[project_id type],
                                    message: MESSAGE }
end
