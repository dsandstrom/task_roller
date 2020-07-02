# frozen_string_literal: true

class Resolution < ApplicationRecord
  belongs_to :issue
  belongs_to :user

  validates :issue_id, presence: true
  validates :issue, presence: true, if: :issue_id
  validates :user_id, presence: true
  validates :user, presence: true, if: :user_id

  validate :issue_available

  # one pending resolution, one approved, any disapproved
  def issue_available
    return unless issue

    validate_issue_has_no_pending
    validate_issue_has_no_approved
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
    return false unless issue.valid?

    update(approved: true) && issue.close
  end

  # TODO: should Resolution#disapprove re-open the issue or wait for reviewer
  def disapprove
    return false unless issue.valid?

    update(approved: false) && issue.open
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

  private

    def issue_resolutions
      issue&.current_resolutions
    end

    def validate_issue_has_no_pending
      return unless issue_resolutions

      pending = issue_resolutions.pending
      pending = pending.where('resolutions.id != ?', id) if id
      return if pending.none?

      errors.add(:issue_id, 'already waiting for a resolution')
    end

    def validate_issue_has_no_approved
      return unless issue_resolutions

      approved = issue_resolutions.approved
      approved = approved.where('resolutions.id != ?', id) if id
      return if approved.none?

      errors.add(:issue_id, 'already approved')
    end
end
