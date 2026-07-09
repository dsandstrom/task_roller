# frozen_string_literal: true

class TaskConnection < ApplicationRecord
  validate :target_has_options
  validate :matching_projects

  belongs_to :user
  # current task
  belongs_to :source, class_name: 'Task'
  # task current task duplicates
  belongs_to :target, class_name: 'Task'

  def target_options
    @target_options ||= build_target_options(source)
  end

  def subscribe_user
    return unless user && target && source&.user

    [source, target].each { |t| t&.subscribe_user(user) }
    target.task_subscriptions.create(user_id: source.user_id)
  end

  private

    def target_has_options
      return if source.blank? || target_options&.any?

      errors.add(:target_id, 'has no options')
    end

    def matching_projects
      return unless source && target
      return if source.project.present? && source.project == target.project

      errors.add(:target_id, 'wrong project')
    end

    def build_target_options(source)
      return unless source&.id && source.project

      tasks = source.project.tasks
      tasks&.where&.not(id: source.id)
    end
end
