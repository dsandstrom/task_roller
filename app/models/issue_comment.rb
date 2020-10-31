# frozen_string_literal: true

class IssueComment < RollerComment
  belongs_to :issue, foreign_key: :roller_id, inverse_of: :comments

  validates :roller_id, presence: true
  validates :issue, presence: true, if: :roller_id

  def subscribe_user(subscriber = nil)
    return unless issue

    subscriber ||= user
    return unless subscriber

    issue.subscribe_user(subscriber)
  end
end
