# frozen_string_literal: true

class IssueType < ApplicationRecord
  ICON_OPTIONS = IconFileReader.new.options.freeze
  COLOR_OPTIONS = %w[default blue brown green purple red yellow].freeze

  acts_as_list
  default_scope { order(position: :asc) }

  has_many :search_results, dependent: nil

  validates :icon, presence: true, inclusion: { in: ICON_OPTIONS }
  validates :name, presence: true, length: { maximum: 100 },
                   uniqueness: { case_sensitive: false }
  validates :color, presence: true, inclusion: { in: COLOR_OPTIONS }

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
