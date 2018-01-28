# frozen_string_literal: true

require "rails_helper"

RSpec.describe "issue_types/new", type: :view do
  before(:each) { assign(:issue_type, IssueType.new) }

  it "renders new issue_type form" do
    render

    assert_select "form[action=?][method=?]", issue_types_path, "post" do
      assert_select "input[name=?]", "issue_type[name]"

      assert_select "input[name=?]", "issue_type[icon]"

      assert_select "input[name=?]", "issue_type[color]"
    end
  end
end
