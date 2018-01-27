# frozen_string_literal: true

class RollerType < ApplicationRecord
  FONT_FILE = Rails.root.join('app', 'assets', 'fonts', 'task-roller.svg')
  RESERVED_ICON_NAMES = %w[arrow-up arrow-down arrow-left arrow-right thumbsup
                           thumbsdown close checkmark eye eye-disabled heart
                           heart-outline hamburger delete plus].freeze

  validates :name, presence: true, length: { maximum: 100 },
                   uniqueness: { scope: :type }
  # TODO: add options for icon and color
  # TODO: validate icon, color are one of the options
  validates :icon, presence: true
  validates :color, presence: true
  validates :type, presence: true

  def self.icon_options
    icon_names = {}

    File.open(FONT_FILE, 'r') do |f|
      f.each_line do |l|
        matches = l.match(/glyph-name="(\w+|\w+\-\w+)"\sunicode="&#(\d+)\;\"/)
        next unless matches && matches.length > 2
        next if RESERVED_ICON_NAMES.include?(matches[1])
        icon_names[matches[1]] = matches[2]
      end
    end

    icon_names
  end
end
