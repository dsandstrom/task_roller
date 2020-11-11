# frozen_string_literal: true

require "rails_helper"

RSpec.describe "issue_reopenings/new", type: :view do
  let(:issue) { Fabricate(:issue) }
  let(:path) { issue_reopenings_path(issue) }

  before(:each) do
    assign(:issue, issue)
    assign(:issue_reopening, IssueReopening.new(issue: issue))
  end

  it "renders new issue_reopening form" do
    render

    assert_select "form[action=?][method=?]", path, "post" do
    end
  end
end
