# frozen_string_literal: true

require "rails_helper"

RSpec.describe "help/workflows", type: :view do
  it "renders links" do
    render

    expect(rendered).to have_link(nil, href: issue_types_help_path)
    expect(rendered).to have_link(nil, href: user_types_help_path)
  end
end
