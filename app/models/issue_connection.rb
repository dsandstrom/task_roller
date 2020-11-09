# frozen_string_literal: true

class IssueConnection < ApplicationRecord
  validates :source_id, presence: true
  validates :target_id, presence: true
  validates :user_id, presence: true

  belongs_to :user
  # current issue
  belongs_to :source, class_name: 'Issue', inverse_of: :source_connection
  # issue current issue duplicates
  belongs_to :target, class_name: 'Issue', inverse_of: :target_connections

  validate :target_has_options
  validate :matching_projects

  def target_options
    @target_options ||=
      (source.project&.issues&.where&.not(id: source.id) if source&.id)
  end

  def subscribe_user
    return unless target && source&.user

    target.issue_subscriptions.create(user_id: source.user_id)
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
end
