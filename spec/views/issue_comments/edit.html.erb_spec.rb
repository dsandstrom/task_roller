# frozen_string_literal: true

require "rails_helper"

RSpec.describe "issue_comments/edit", type: :view do
  let(:user) { Fabricate(:user_worker) }
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:issue) { Fabricate(:issue, project: project) }
  let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

  let(:url) { issue_comment_url(issue_comment) }

  before(:each) do
    assign(:category, category)
    assign(:project, project)
    assign(:issue, issue)
    assign(:issue_comment, issue_comment)
  end

  it "renders the edit issue_comment form" do
    render

    assert_select "form[action=?][method=?]", url, "post" do
      assert_select "textarea[name=?]", "issue_comment[body]"
    end
  end
end
