# frozen_string_literal: true

class IssueConnection < RollerConnection
  # current issue
  belongs_to :source, class_name: 'Issue', inverse_of: :source_issue_connections
  # issue current issue duplicates
  belongs_to :target, class_name: 'Issue', inverse_of: :target_issue_connections
end
