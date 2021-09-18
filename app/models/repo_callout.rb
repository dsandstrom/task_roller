# frozen_string_literal: true

# TODO: add 'progresses' action to add progression

class RepoCallout < ApplicationRecord
  ACTION_OPTIONS = %w[start pause complete].freeze
  MESSAGE_REGEX = /
    ((starts?|fix(?:e[ds])?|(?:pause|close|complete)[ds]?)\s
    (?:task)?\s?[\#\-]?
    (\d+))
  /ix.freeze

  validates :task_id, presence: true
  validates :action, presence: true, inclusion: { in: ACTION_OPTIONS }
  validates :commit_sha, presence: true
  validates :commit_message, presence: true
  validates :commit_message_part, presence: true
  validates :task_id, uniqueness: { scope: :commit_sha }

  belongs_to :task
  belongs_to :user, optional: true

  def unfinished_progressions
    @unfinished_progressions ||=
      task.progressions.unfinished.where(user_id: user.id)
  end

  def process_commit_message
    return if action && task_id

    matches = commit_message_part.match(MESSAGE_REGEX)
    return unless matches && matches.size == 4

    action = generate_action(matches[2])
    task = Task.find_by(id: matches[3].to_i)
    return unless action && task

    self.action = action
    self.task_id = task.id
  end

  def perform_action
    return unless user && task

    case action
    when 'start'
      start_task
    when 'pause'
      pause_task
    when 'complete'
      finish_task
    end

    task.update_status
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

    def start_task
      return unless task.open? && unfinished_progressions.none?

      task.progressions.create(user: user)
    end

    def pause_task
      unfinished_progressions.all?(&:finish)
    end

    def finish_task
      return if task.closed?

      task.finish if task.reviews.create(user: user)
    end
end
