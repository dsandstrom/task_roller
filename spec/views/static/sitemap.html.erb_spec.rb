# frozen_string_literal: true

require "rails_helper"

RSpec.describe "static/sitemap", type: :view do
  let(:user) { Fabricate(:user) }

  before do
    assign(:categories, [Fabricate(:category)])
    enable_can(view, user)
  end

  it "renders page" do
    render template: subject, layout: "layouts/application"

    assert_select "h1", "Sitemap"
  end
end
