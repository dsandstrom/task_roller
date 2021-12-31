# frozen_string_literal: true

class IssueComment < ApplicationRecord
  validates :body, presence: true

  belongs_to :issue, inverse_of: :comments
  belongs_to :user
  has_many :notifications, class_name: 'IssueNotification', dependent: :destroy

  default_scope { order(created_at: :asc) }

  def subscribe_user
    return unless issue && user

    issue.subscribe_user(user)
  end

  def body_html
    @body_html ||= (RollerMarkdown.new.render(body) || '')
  end

  def notify_subscribers
    issue&.notify_of_comment(comment: self)
  end
end
