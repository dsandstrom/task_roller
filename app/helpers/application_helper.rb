# frozen_string_literal: true

module ApplicationHelper
  DATE_FORMAT = '%-m/%-d'
  TIME_FORMAT = '%-l:%M%P'

  # TODO: test
  def format_date(value)
    zone = 'Pacific Time (US & Canada)'
    now = Time.now.in_time_zone(zone)
    value = value.in_time_zone(zone)

    return "#{time_ago_in_words(value)} ago" if recent?(value, now)
    return value.strftime(TIME_FORMAT) if same_day?(value, now)

    if same_year?(value, now)
      return value.strftime("#{DATE_FORMAT}-#{TIME_FORMAT}")
    end

    value.strftime("#{DATE_FORMAT}/%Y-#{TIME_FORMAT}")
  end

  def menu_link(text, path)
    klass = 'menu-link'
    klass += ' current-page' if current_page?(path)

    content_tag :p do
      link_to(text, path, class: klass)
    end
  end

  def icon(name)
    content_tag :i, nil, class: "icon-#{name}"
  end

  def divider
    content_tag :span, '|', class: 'divider'
  end

  def divider_with_spaces
    safe_join([' ', divider, ' '])
  end

  private

    def enable_page_title(title)
      title = "Task Roller | #{title}"
      content_for(:title, truncate(title, length: 70, omission: ''))
    end

    def roller_tag(text, klass)
      content_tag :span, text, class: "tag tag-#{klass}"
    end

    def visible_tag(object)
      return if object.visible?

      roller_tag 'Invisible', 'invisible'
    end

    def internal_tag(object)
      return unless object.internal?

      roller_tag 'Internal', 'internal'
    end

    def recent?(first, second)
      first > (second - 1.hour)
    end

    def same_day?(first, second)
      first.year == second.year && first.month == second.month &&
        first.day == second.day
    end

    def same_year?(first, second)
      first.year == second.year
    end

    def navitize(links)
      links.map do |value, url, options = {}|
        link_to_unless_current(value, url, options)
      end
    end
end
