# frozen_string_literal: true

module TestHelpers
  module Pagination
    def page(array, current_page = 1)
      Kaminari.paginate_array(array).page(current_page)
    end
  end
end
