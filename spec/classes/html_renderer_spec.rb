# frozen_string_literal: true

require "rails_helper"

RSpec.describe HTMLRenderer, type: :class do
  before { @html_renderer = HTMLRenderer.new }

  subject { @html_renderer }

  it { is_expected.to be_a(Redcarpet::Render::HTML) }

  describe "#initialize" do
    it "sets options" do
      expect(subject.instance_variable_get(:@options))
        .to eq(filter_html: true, hard_wrap: true, no_images: true,
               no_styles: true, prettify: true, safe_links_only: true)
    end
  end
end
