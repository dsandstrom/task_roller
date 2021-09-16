# frozen_string_literal: true

class Progression < ApplicationRecord
  TIME_ZONE = 'Pacific Time (US & Canada)'

  belongs_to :task
  belongs_to :user

  validates :task_id, presence: true
  validates :task, presence: true, if: :task_id
  validates :user_id, presence: true
  validates :user, presence: true, if: :user_id

  validate :user_available

  # user shouldn't have 2 in progress for the task
  def user_available
    return unless user && task_id

    unfinished = user.progressions.unfinished
    unfinished = unfinished.where(progressions: { task_id: task_id })
    unfinished = unfinished.where.not(progressions: { id: id }) if id
    return if unfinished.none?

    errors.add(:user_id, 'not available')
  end

  # CLASS

  def self.unfinished
    where(finished: false)
  end

  def self.finished
    where(finished: true)
  end

  # INSTANCE

  def finish
    update finished: true, finished_at: Time.zone.now
  end

  def start_date
    @start_date ||=
      created_at.in_time_zone(TIME_ZONE).strftime(date_format(created_at))
  end

  def finish_date
    @finish_date ||=
      if finished? && finished_at
        finished_at.in_time_zone(TIME_ZONE).strftime(date_format(finished_at))
      end
  end

  private

    def date_format(date)
      date_format = '%-m/%-d'
      return date_format if date.year == Time.zone.now.year

      "#{date_format}/%Y"
    end
end
