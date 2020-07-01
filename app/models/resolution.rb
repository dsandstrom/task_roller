# frozen_string_literal: true

class Resolution < ApplicationRecord
  belongs_to :issue
  belongs_to :user

  validates :issue_id, presence: true
  validates :issue, presence: true, if: :issue_id
  validates :user_id, presence: true
  validates :user, presence: true, if: :user_id

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
end
