# frozen_string_literal: true

class RollerType < ApplicationRecord
  # TODO: make separate class/helper
  private_class_method def self.pull_icon_options_from_font
    icon_names = []
    File.open(FONT_FILE, 'r') do |f|
      f.each_line do |l|
        matches = l.match(/glyph-name="(\w+|\w+\-\w+)"\sunicode="&#\d+\;\"/)
        next unless matches && matches[1]
        next if RESERVED_ICON_NAMES.include?(matches[1])
        icon_names << matches[1]
      end
    end
    icon_names
  end

  # TODO: sort by name
  private_class_method def self.set_icon_options
    pull_icon_options_from_font
  rescue Errno::ENOENT
    raise 'App Error: Add icon font files'
  end

  FONT_FILE = Rails.root.join('app', 'assets', 'fonts', 'task-roller.svg')
  RESERVED_ICON_NAMES = %w[arrow-up arrow-down arrow-left arrow-right thumbsup
                           thumbsdown close checkmark eye eye-disabled heart
                           heart-outline hamburger delete plus alert].freeze
  COLOR_OPTIONS = %w[default blue brown green purple red yellow].freeze
  ICON_OPTIONS = set_icon_options.freeze

  validates :icon, presence: true, inclusion: { in: ICON_OPTIONS }
  validates :name, presence: true, length: { maximum: 100 },
                   uniqueness: { scope: :type }
  validates :color, presence: true, inclusion: { in: COLOR_OPTIONS }
  validates :type, presence: true
end
