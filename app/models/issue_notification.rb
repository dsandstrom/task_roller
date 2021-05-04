# frozen_string_literal: true

# TODO: show notifications in partials
# TODO: add views

class IssueNotification < ApplicationRecord
  EVENT_OPTIONS = %w[comment new status].freeze

  validates :issue_id, presence: true
  validates :user_id, presence: true

  validates :event, inclusion: { in: EVENT_OPTIONS }
  validates :details, length: { maximum: 100 }

  belongs_to :user
  belongs_to :issue
  belongs_to :issue_comment, optional: true

  def full_event
    @full_event ||= build_full_event
  end

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
        options[:comment] = issue_comment
      end
      options
    end

    def build_full_event
      case event
      when 'comment'
        'New Comment'
      when 'status'
        'Status Change'
      when 'new'
        'New Issue'
      else
        event
      end
    end
end
