# frozen_string_literal: true

class RepoCallout < ApplicationRecord
  ACTION_OPTIONS = %w[start pause complete].freeze
  MESSAGE_REGEX = /
    (starts?|fix(?:e[ds])?|(?:pause|close|complete)[ds]?)\s
    (?:task)?\s?\#?
    (\d+)
  /ix.freeze

  validates :task_id, presence: true
  validates :action, presence: true, inclusion: { in: ACTION_OPTIONS }
  validates :commit_sha, presence: true
  validates :commit_message, presence: true
  validates :task_id, uniqueness: { scope: :commit_sha }

  belongs_to :task
  belongs_to :user, optional: true

  def process_commit_message
    return if action && task_id

    matches = commit_message.match(MESSAGE_REGEX)
    return unless matches && matches.size == 3

    action = generate_action(matches[1])
    task = Task.find_by(id: matches[2].to_i)
    return unless action && task

    self.action = action
    self.task_id = task.id
  end

  private

    def generate_action(part)
      if look_like_start?(part)
        'start'
      elsif look_like_pause?(part)
        'pause'
      elsif look_like_complete?(part)
        'complete'
      end
    end

    def look_like_start?(part)
      part.match?(/start/i)
    end

    def look_like_pause?(part)
      part.match?(/pause/i)
    end

    def look_like_complete?(part)
      part.match?(/fix|close|complete/i)
    end
end
