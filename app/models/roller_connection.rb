# frozen_string_literal: true

class RollerConnection < ApplicationRecord
  validates :source_id, presence: true
  validates :target_id, presence: true

  validate :target_has_options
  validate :matching_projects

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
