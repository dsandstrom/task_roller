# frozen_string_literal: true

require "rails_helper"

RSpec.describe "static/sitemap", type: :view do
  it "renders page" do
    render

    assert_select "h1", "Sitemap"
  end
end
