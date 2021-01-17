# frozen_string_literal: true

require "rails_helper"

RSpec.describe "static/unauthorized", type: :view do
  it "renders page" do
    render template: subject, layout: "layouts/application"

    assert_select "h1", "Unauthorized"
  end
end
