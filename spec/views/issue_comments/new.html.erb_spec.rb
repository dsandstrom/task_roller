# frozen_string_literal: true

require "rails_helper"

RSpec.describe "issue_comments/new", type: :view do
  let(:user) { Fabricate(:user_worker) }
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:issue) { Fabricate(:issue, project: project) }

  let(:url) { issue_issue_comments_url(issue) }

  context "for an admin" do
    let(:current_user) { Fabricate(:user_admin) }

    before(:each) do
      enable_can(view, current_user)
      assign(:issue, issue)
      assign(:issue_comment, issue.comments.build)
    end

    it "renders new issue_comment form" do
      render

      assert_select "form[action=?][method=?]", url, "post" do
        assert_select "textarea[name=?]", "issue_comment[body]"
      end
    end
  end
end
