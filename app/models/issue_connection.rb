# frozen_string_literal: true

class IssueConnection < RollerConnection
  # current issue
  belongs_to :source, class_name: 'Issue', inverse_of: :source_issue_connection
  # issue current issue duplicates
  belongs_to :target, class_name: 'Issue', inverse_of: :target_issue_connections

  def target_options
    @target_options ||=
      (source.project&.issues&.where&.not(id: source.id) if source&.id)
  end

  def subscribe_user
    return unless target && source&.user

    target.issue_subscriptions.create(user_id: source.user_id)
  end
end
