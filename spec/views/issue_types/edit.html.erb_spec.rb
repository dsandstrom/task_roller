# frozen_string_literal: true

require "rails_helper"

RSpec.describe "issue_types/edit", type: :view do
  let(:issue_type) { Fabricate(:issue_type) }
  let(:url) { issue_type_path(issue_type) }

  before(:each) { assign(:issue_type, issue_type) }

  it "renders the edit issue_type form" do
    render

    assert_select "form[action=?][method=?]", url, "post" do
      assert_select "input[name=?]", "issue_type[name]"

      assert_select "input[name=?]", "issue_type[icon]"

      assert_select "input[name=?]", "issue_type[color]"
    end
  end
end
