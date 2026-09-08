module Filter
  extend ActiveSupport::Concern

  class_methods do # rubocop:disable Metrics/BlockLength
    def filter_by_id(query)
      return all if query.blank?

      where(id: query.to_i)
    end

    def split_id(query)
      return unless query

      number = query[/\d+/]
      query = query.sub(/(issue|task)?\s?[#-]?\d+\s?/i, '') if number
      [number&.to_i, query]
    end

    def filter_by_status(status_options, status)
      return all unless status
      return all unless status_options.include?(status.to_sym)

      send("all_#{status}")
    end

    def filter_by_string(table_name, query)
      return all if query.blank?

      where(
        "#{table_name}.summary ILIKE :query OR " \
        "#{table_name}.description ILIKE :query",
        query: "%#{query}%"
      )
    end

    private

      def valid_filter_order?(column, direction)
        direction.present? && %w[created updated priority].include?(column) &&
          %w[asc desc].include?(direction)
      end

      def build_order_param(table_name, default_order, order)
        return default_order if order.blank?

        column, direction = order.split(',')
        return default_order unless valid_filter_order?(column, direction)

        if column == 'priority'
          "#{table_name}.priority_level #{direction}, " \
            "#{table_name}.created_at asc"
        else
          "#{table_name}.#{column}_at #{direction}"
        end
      end
  end
end
