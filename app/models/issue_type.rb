# frozen_string_literal: true

class IssueType < RollerType
  acts_as_list scope: [:type]
  default_scope { order(position: :asc) }
end
