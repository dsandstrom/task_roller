# frozen_string_literal: true

class TaskComment < ApplicationRecord
  validates :task_id, presence: true
  validates :task, presence: true, if: :task_id
  validates :user_id, presence: true
  validates :user, presence: true, if: :user_id
  validates :body, presence: true

  belongs_to :task, inverse_of: :comments
  belongs_to :user
  has_many :notifications, class_name: 'TaskNotification', dependent: :destroy

  default_scope { order(created_at: :asc) }

  def subscribe_user
    return unless task && user

    task.subscribe_user(user)
  end

  def body_html
    @body_html ||= (RollerMarkdown.new.render(body) || '')
  end

  def notify_subscribers
    task&.notify_of_comment(comment: self)
  end
end
