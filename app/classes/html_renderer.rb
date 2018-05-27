# frozen_string_literal: true

class HTMLRenderer < Redcarpet::Render::HTML
  OPTIONS = { filter_html: true, hard_wrap: true, no_images: true,
              no_styles: true, prettify: true, safe_links_only: true }.freeze

  def initialize(*_)
    super OPTIONS.dup
  end
end
