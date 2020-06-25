# frozen_string_literal: true

class Review < ApplicationRecord
  belongs_to :task
  belongs_to :user

  validates :task_id, presence: true
  validates :task, presence: true
  validates :user_id, presence: true
  validates :user, presence: true

  validate :task_available

  # one pending review, one approved, any disapproved
  def task_available
    return unless task

    validate_task_has_no_pending
    validate_task_has_no_approved
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

  # INSTANCE

  def disapproved?
    approved == false
  end

  def pending?
    approved.nil?
  end

  def approve
    return false unless task.valid?

    update(approved: true) && task.close
  end

  def disapprove
    return false unless task.valid?

    update(approved: false) && task.open
  end

  private

    def validate_task_has_no_pending
      return unless task&.reviews

      pending = task.reviews.pending
      pending = pending.where('reviews.id != ?', id) if id
      return if pending.none?

      errors.add(:task_id, 'already waiting for a review')
    end

    def validate_task_has_no_approved
      return unless task&.reviews

      approved = task.reviews.approved
      approved = approved.where('reviews.id != ?', id) if id
      return if approved.none?

      errors.add(:task_id, 'already approved')
    end
end
