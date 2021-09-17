# frozen_string_literal: true

class RepoCallout < ApplicationRecord
  ACTION_OPTIONS = %w[start pause complete].freeze

  validates :task_id, presence: true
  validates :action, presence: true, inclusion: { in: ACTION_OPTIONS }
  validates :commit_sha, presence: true
  validates :commit_message, presence: true
  validates :task_id, uniqueness: { scope: :commit_sha }

  belongs_to :task
  belongs_to :user, optional: true
end
