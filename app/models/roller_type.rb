# frozen_string_literal: true

# TODO: don't allow destroying when issues
# TODO: when destroying, add way to move issues to new type

# Base class for Issue and Task types (eg. Bug, New Feature)
class RollerType < ApplicationRecord
  ICON_OPTIONS = IconFileReader.new.options.freeze
  COLOR_OPTIONS = %w[default blue brown green purple red yellow].freeze

  acts_as_list scope: [:type]
  default_scope { order(position: :asc) }

  validates :icon, presence: true, inclusion: { in: ICON_OPTIONS }
  validates :name, presence: true, length: { maximum: 100 },
                   uniqueness: { scope: :type }
  validates :color, presence: true, inclusion: { in: COLOR_OPTIONS }
  validates :type, presence: true

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
