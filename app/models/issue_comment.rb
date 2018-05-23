# frozen_string_literal: true

class IssueComment < RollerComment
  belongs_to :issue, foreign_key: :roller_id, inverse_of: :comments

  validates :roller_id, presence: true
end
