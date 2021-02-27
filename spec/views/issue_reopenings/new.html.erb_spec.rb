# frozen_string_literal: true

require "rails_helper"

RSpec.describe "issue_reopenings/new", type: :view do
  let(:issue) { Fabricate(:issue) }
  let(:path) { issue_reopenings_path(issue) }

  context "for an admin" do
    let(:current_user) { Fabricate(:user_admin) }

    before(:each) do
      enable_can(view, current_user)
      assign(:issue, issue)
      assign(:issue_reopening, IssueReopening.new(issue: issue))
    end

    it "renders new issue_reopening form" do
      render

      assert_select "form[action=?][method=?]", path, "post"
    end
  end
end
