# frozen_string_literal: true

class Review < ApplicationRecord
  belongs_to :task
  belongs_to :user

  validates :task_id, presence: true
  validates :user_id, presence: true

  validate :task_available

  # one pending review, one approved, any disapproved
  def task_available
    return unless task

    validate_task_has_no_other_pending
    validate_task_has_no_other_approved
  end

  # CLASS

  def self.pending
    where(approved: nil)
  end

  def self.disapproved
    where(approved: false)
  end

  def self.approved
    where(approved: true)
  end

  private

    def validate_task_has_no_other_pending
      pending = task.reviews.pending
      pending = pending.where('reviews.id != ?', id) if id
      return if pending.none?

      errors.add(:task_id, 'already has a pending review')
    end

    def validate_task_has_no_other_approved
      approved = task.reviews.approved
      approved = approved.where('reviews.id != ?', id) if id
      return if approved.none?

      errors.add(:task_id, 'already has a approved review')
    end
end
