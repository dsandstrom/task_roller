# frozen_string_literal: true

class IssueType < RollerType
  acts_as_list scope: [:type]
  default_scope { order(position: :asc) }

  def reposition(direction)
    case direction
    when 'up'
      return move_higher
    when 'down'
      return move_lower
    end

    false
  end
end
