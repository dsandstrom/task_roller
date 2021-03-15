# frozen_string_literal: true

# TODO: send email after creation

class IssueNotification < ApplicationRecord
  EVENT_OPTIONS = %w[comment new status].freeze

  validates :issue_id, presence: true
  validates :user_id, presence: true

  validates :event, inclusion: { in: EVENT_OPTIONS }
  validates :details, length: { maximum: 100 }

  belongs_to :user
  belongs_to :issue
end
