# frozen_string_literal: true

class RollerMarkdown
  OPTIONS = { no_intra_emphasis: true, tables: false, autolink: true,
              strikethrough: true, space_after_headers: true,
              superscript: false, underline: false, quote: false,
              footnotes: false, fenced_code_blocks: true,
              disable_indented_code_blocks: true }.freeze

  def initialize
    @markdown = Redcarpet::Markdown.new(HTMLRenderer.new, OPTIONS.dup)
  end

  def render(value)
    return unless @markdown && value

    @markdown.render(value)
  end
end
