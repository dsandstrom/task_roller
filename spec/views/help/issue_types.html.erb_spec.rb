# frozen_string_literal: true

require "rails_helper"

RSpec.describe "help/issue_types", type: :view do
  it "renders links" do
    render template: subject, layout: "layouts/application"

    expect(rendered).to have_link(nil, href: user_types_help_path)
    expect(rendered).to have_link(nil, href: workflows_help_path)
  end
end
