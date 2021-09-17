# frozen_string_literal: true

class RepoCallout < ApplicationRecord
  validates :task_id, presence: true
  validates :action, presence: true
  validates :commit_sha, presence: true
  validates :commit_message, presence: true
  validates :task_id, uniqueness: { scope: :commit_sha }

  belongs_to :task
  belongs_to :user, optional: true
end
