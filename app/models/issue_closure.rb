# frozen_string_literal: true

class IssueClosure < ApplicationRecord
  validates :issue_id, presence: true
  validates :user_id, presence: true

  belongs_to :issue
  belongs_to :user

  def subscribe_user
    return unless user && issue

    issue.subscribe_user(user)
  end
end
