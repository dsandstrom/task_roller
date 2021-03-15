# frozen_string_literal: true

class IssueNotification < ApplicationRecord
  EVENT_OPTIONS = %w[comment new status].freeze

  validates :issue_id, presence: true
  validates :user_id, presence: true

  validates :event, inclusion: { in: EVENT_OPTIONS }
  validates :details, length: { maximum: 100 }

  belongs_to :user
  belongs_to :issue

  def send_email
    return unless valid?

    options = { issue: issue, user: user }
    if event == 'status'
      options[:old_status], options[:new_status] = details&.split(',')
    end
    return unless options.all? { |_, value| value.present? }

    IssueMailer.with(options).send(event).deliver_later
  end
end
