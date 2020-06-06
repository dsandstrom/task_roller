# frozen_string_literal: true

class IconFileReader
  FONT_FILE = Rails.root.join('app', 'assets', 'fonts', 'task-roller.svg')
  RESERVED_ICON_NAMES =
    %w[alert arrow-down arrow-left arrow-right arrow-up checkmark close delete
       eye eye-disabled hamburger heart heart-outline thumbsup thumbsdown
       person person-add person-group plus bold italic code header strikethrough
       link quote unordered-list ordered-list split arrow-expand].freeze

  def new; end

  def options
    pull_options_from_font&.sort
  rescue Errno::ENOENT
    raise 'App Error: Add icon font files'
  end

  private

    def pull_options_from_font
      icon_names = []
      File.open(FONT_FILE, 'r') do |f|
        f.each_line do |l|
          matches = l.match(/glyph-name="(\w+|\w+-\w+)"\sunicode="&#\d+;"/)
          next unless matches && matches[1]
          next if RESERVED_ICON_NAMES.include?(matches[1])

          icon_names << matches[1]
        end
      end
      icon_names
    end
end
