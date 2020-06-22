# frozen_string_literal: true

class Progression < ApplicationRecord
  belongs_to :task
  belongs_to :user

  validates :task_id, presence: true
  validates :user_id, presence: true

  # CLASS

  def self.unfinished
    where(finished: false)
  end

  def self.finished
    where(finished: true)
  end
end
