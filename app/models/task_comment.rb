# frozen_string_literal: true

class TaskComment < RollerComment
  belongs_to :task, foreign_key: :roller_id, inverse_of: :comments

  validates :roller_id, presence: true
  validates :task, presence: true, if: :roller_id
end
