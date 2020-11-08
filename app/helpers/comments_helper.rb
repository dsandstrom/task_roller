# frozen_string_literal: true

module CommentsHelper
  # TODO: test
  # TODO: when current day, just show time
  def format_date(value)
    date_format = '%-m/%-d'
    time_format = '%-l:%M%P'

    zone = 'Pacific Time (US & Canada)'
    now = Time.now.in_time_zone(zone)
    value = value.in_time_zone(zone)

    if value.year == now.year
      return value.strftime("#{date_format}-#{time_format}")
    end

    value.strftime("#{date_format}/%Y-#{time_format}")
  end

  def format_day(value)
    date_format = '%-m/%-d'

    zone = 'Pacific Time (US & Canada)'
    now = Time.now.in_time_zone(zone)
    value = value.in_time_zone(zone)

    return value.strftime(date_format) if value.year == now.year

    value.strftime("#{date_format}/%Y")
  end

  def formatted_dates(object)
    created_date = format_date(object.created_at)
    return created_date if object.updated_at == object.created_at

    "#{created_date} (ed. #{format_date(object.updated_at)})"
  end
end
