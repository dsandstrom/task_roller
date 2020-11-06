# frozen_string_literal: true

# TODO: allow reporting comments to admin
# TODO: color code comment css (op-blue, bob-pink, sally-yellow)
# makes it easier to recognize comments from same user

class IssueComment < ApplicationRecord
  validates :issue_id, presence: true
  validates :issue, presence: true, if: :issue_id
  validates :user_id, presence: true
  validates :user, presence: true, if: :user_id
  validates :body, presence: true

  belongs_to :issue, foreign_key: :issue_id, inverse_of: :comments
  belongs_to :user

  default_scope { order(created_at: :asc) }

  def subscribe_user
    return unless issue && user

    issue.subscribe_user(user)
  end

  def body_html
    @body_html ||= (RollerMarkdown.new.render(body) || '')
  end
end
