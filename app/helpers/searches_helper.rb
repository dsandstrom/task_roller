# frozen_string_literal: true

module SearchesHelper
  def search_header(heading = nil)
    title = 'Issue & Task Search'
    enable_page_title title
    content_for :header do
      concat content_tag(:h1, title)
      concat content_tag(:h2, heading) if heading.present?
    end
  end
end
