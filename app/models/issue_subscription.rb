# frozen_string_literal: true

class IssueSubscription < ApplicationRecord
  MESSAGE = 'already subscribed to issue'
  validates :user_id, presence: true,
                      uniqueness: { scope: :issue_id, message: MESSAGE }
  validates :issue_id, presence: true

  belongs_to :user, class_name: 'User'
  belongs_to :issue, class_name: 'Issue'
end
