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

  def full_event
    @full_event ||= build_full_event
  end

  def send_email
    return if Rails.env.development?
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

    def build_full_event
      case event
      when 'comment'
        'New Comment'
      when 'status'
        'Status Change'
      when 'new'
        'New Task'
      else
        event
      end
    end
end
