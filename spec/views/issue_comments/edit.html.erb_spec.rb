# frozen_string_literal: true

require "rails_helper"

RSpec.describe "issue_comments/edit", type: :view do
  let(:user) { Fabricate(:user_worker) }
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:issue) { Fabricate(:issue, project: project) }
  let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

  let(:url) do
    category_project_issue_issue_comment_url(category, project, issue,
                                             issue_comment)
  end

  before(:each) do
    assign(:category, category)
    assign(:project, project)
    assign(:issue, issue)
    assign(:comment, issue_comment)
    assign(:user_options, [["Type 1", [["Name 1", 12], ["Name 2", 14]]]])
  end

  it "renders the edit issue_comment form" do
    render

    assert_select "form[action=?][method=?]", url, "post" do
      assert_select "select[name=?]", "issue_comment[user_id]"

      assert_select "textarea[name=?]", "issue_comment[body]"
    end
  end
end
