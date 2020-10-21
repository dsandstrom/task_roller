# frozen_string_literal: true

class IssueSubscription < ApplicationRecord
  validates :user_id, presence: true
  validates :issue_id, presence: true

  belongs_to :user, class_name: 'User'
  belongs_to :issue, class_name: 'Issue'
end
