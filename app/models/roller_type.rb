# frozen_string_literal: true

class RollerType < ApplicationRecord
  FONT_FILE = Rails.root.join('app', 'assets', 'fonts', 'task-roller.svg')
  RESERVED_ICON_NAMES = %w[arrow-up arrow-down arrow-left arrow-right thumbsup
                           thumbsdown close checkmark eye eye-disabled heart
                           heart-outline hamburger delete plus].freeze
  COLOR_OPTIONS = %w[green yellow red brown gray blue purple].freeze

  private_class_method def self.pull_icon_options_from_font
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

  def self.icon_options
    pull_icon_options_from_font
  rescue Errno::ENOENT
    raise 'App Error: Add icon font files'
  end

  validates :icon, presence: true, inclusion: { in: icon_options }
  validates :name, presence: true, length: { maximum: 100 },
                   uniqueness: { scope: :type }
  validates :color, presence: true, inclusion: { in: COLOR_OPTIONS }
  validates :type, presence: true
end
