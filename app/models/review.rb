# frozen_string_literal: true

class Review < ApplicationRecord
  belongs_to :task
  belongs_to :user
  belongs_to :repo_callout, optional: true

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

  def self.concluded
    approved.or(disapproved)
  end

  # INSTANCE

  def disapproved?
    @disapproved_ = approved == false if @disapproved_.nil?
    @disapproved_
  end

  def pending?
    @pending_ = approved.nil? if @pending_.nil?
    @pending_
  end

  def approve(user = nil)
    return false unless task.valid?

    attrs = { approved: true }
    attrs.merge!(user_id: user.id) if user
    update(attrs) && task.close
  end

  def disapprove(user = nil)
    return false unless task.valid?

    attrs = { approved: false }
    attrs.merge!(user_id: user.id) if user
    update(attrs) && task.reopen
  end

  def status
    @status ||=
      if pending?
        'pending'
      elsif approved?
        'approved'
      else
        'disapproved'
      end
  end

  def subscribe_user
    return unless task && user

    task.task_subscriptions.create(user_id: user.id)
  end

  private

    def task_reviews
      task&.current_reviews
    end

    def validate_task_has_no_pending
      return unless task_reviews

      pending = task_reviews.pending
      pending = pending.where.not(reviews: { id: id }) if id
      return if pending.none?

      errors.add(:task_id, 'already waiting for a review')
    end

    def validate_task_has_no_approved
      return unless task_reviews

      approved = task_reviews.approved
      approved = approved.where.not(reviews: { id: id }) if id
      return if approved.none?

      errors.add(:task_id, 'already approved')
    end
end
