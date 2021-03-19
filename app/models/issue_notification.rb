# frozen_string_literal: true

# TODO: add comment_id?

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
    return unless mailer_options.all? { |_, value| value.present? }

    IssueMailer.with(mailer_options).send(event).deliver_later
  end

  private

    def mailer_options
      @mailer_options ||= build_mailer_options
    end

    def build_mailer_options
      options = { issue: issue, user: user }
      case event
      when 'status'
        options[:old_status], options[:new_status] = details&.split(',')
      when 'comment'
        options[:comment] = IssueComment.find_by_id(details) if details.present?
      end
      options
    end
end
