# frozen_string_literal: true

require "rails_helper"

RSpec.describe "issue_closures/new", type: :view do
  let(:issue) { Fabricate(:issue) }
  let(:path) { issue_closures_path(issue) }

  before(:each) do
    assign(:issue, issue)
    assign(:issue_closure, IssueClosure.new(issue: issue))
  end

  it "renders new issue_closure form" do
    render

    assert_select "form[action=?][method=?]", path, "post"
  end
end
