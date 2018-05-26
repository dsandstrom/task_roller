# frozen_string_literal: true

require "rails_helper"

RSpec.describe "issues/show", type: :view do
  before(:each) { @category = assign(:category, Fabricate(:category)) }

  context "when project" do
    before do
      @project = assign(:project, Fabricate(:project, category: @category))
      @issue = assign(:issue, Fabricate(:issue, project: @project))
      @comment = assign(:issue_comment, @issue.comments.build)
      @comments = assign(:comments, [])
    end

    let(:url) do
      category_project_issue_issue_comments_url(@category, @project, @issue)
    end

    it "renders issue's summary" do
      render
      assert_select ".issue-summary", "Issue: #{@issue.summary}"
    end

    it "renders issue's description" do
      render
      assert_select ".issue-description", @issue.description
    end

    it "renders new issue_comment form" do
      render

      assert_select "form[action=?][method=?]", url, "post" do
        assert_select "textarea[name=?]", "issue_comment[body]"
      end
    end

    context "with tasks" do
      it "renders a list of tasks" do
        task = Fabricate(:task, issue: @issue)

        render
        assert_select "#issue-task-#{task.id}"
      end
    end
  end

  context "when no project" do
    before do
      project = Fabricate(:project, category: @category)
      @issue = assign(:issue, Fabricate(:issue, project: project))
      @comment = assign(:issue_comment, @issue.comments.build)
      @comments = assign(:comments, [])
    end

    it "renders summary>" do
      render
      assert_select ".issue-summary", "Issue: #{@issue.summary}"
    end
  end

  context "when no issue_type" do
    before do
      @project = assign(:project, Fabricate(:project, category: @category))
      @issue = assign(:issue, Fabricate(:issue, project: @project))
      @comment = assign(:issue_comment, @issue.comments.build)
      @comments = assign(:comments, [])
      @issue.issue_type.destroy
      @issue.reload
    end

    it "renders summary>" do
      render
      assert_select ".issue-summary", "Issue: #{@issue.summary}"
    end
  end
end
