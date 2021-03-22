# frozen_string_literal: true

class TaskNotification < ApplicationRecord
  EVENT_OPTIONS = %w[comment new status].freeze

  validates :task_id, presence: true
  validates :user_id, presence: true

  validates :details, length: { maximum: 100 }
  validates :event, inclusion: { in: EVENT_OPTIONS }

  belongs_to :user
  belongs_to :task
  belongs_to :task_comment, optional: true

  def send_email
    return unless valid?
    return unless mailer_options.all? { |_, value| value.present? }

    TaskMailer.with(mailer_options).send(event).deliver_later
  end

  private

    def mailer_options
      @mailer_options ||= build_mailer_options
    end

    def build_mailer_options
      options = { task: task, user: user }
      case event
      when 'status'
        options[:old_status], options[:new_status] = details&.split(',')
      when 'comment'
        options[:comment] = task_comment
      end
      options
    end
end
