# frozen_string_literal: true

module CommentsHelper
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

  def format_day(value)
    zone = 'Pacific Time (US & Canada)'
    now = Time.now.in_time_zone(zone)
    value = value.in_time_zone(zone)

    return value.strftime(DATE_FORMAT) if value.year == now.year

    value.strftime("#{DATE_FORMAT}/%Y")
  end

  def formatted_dates(object)
    created_date = format_date(object.created_at)
    return created_date if object.updated_at == object.created_at

    "#{created_date} (ed. #{format_date(object.updated_at)})"
  end

  private

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
end
