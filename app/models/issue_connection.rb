# frozen_string_literal: true

class IssueConnection < RollerConnection
  # current issue
  belongs_to :source, class_name: 'Issue'
  # issue current issue duplicates
  belongs_to :target, class_name: 'Issue'
end
