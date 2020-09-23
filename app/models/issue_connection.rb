# frozen_string_literal: true

# TODO: validate source & target have the same project/category

class IssueConnection < RollerConnection
  # current issue
  belongs_to :source, class_name: 'Issue', inverse_of: :source_issue_connection
  # issue current issue duplicates
  belongs_to :target, class_name: 'Issue', inverse_of: :target_issue_connections

  validate :target_has_options

  def target_options
    @target_options ||=
      (source.project&.issues&.where&.not(id: source.id) if source&.id)
  end

  private

    def target_has_options
      return if source.blank? || target_options&.any?

      errors.add(:target_id, 'has no options')
    end
end
