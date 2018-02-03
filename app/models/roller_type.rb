# frozen_string_literal: true

# TODO: don't allow destroying when issues
# TODO: when destroying, add way to move issues to new type

class RollerType < ApplicationRecord
  ICON_OPTIONS = IconFileReader.new.options.freeze
  COLOR_OPTIONS = %w[default blue brown green purple red yellow].freeze

  validates :icon, presence: true, inclusion: { in: ICON_OPTIONS }
  validates :name, presence: true, length: { maximum: 100 },
                   uniqueness: { scope: :type }
  validates :color, presence: true, inclusion: { in: COLOR_OPTIONS }
  validates :type, presence: true
end
