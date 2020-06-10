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
      assert_select ".issue-description main", @issue.description
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

  context "when issue's user destroyed" do
    before do
      @project = assign(:project, Fabricate(:project, category: @category))
      @issue = assign(:issue, Fabricate(:issue, project: @project))
      @comments = assign(:comments, [])
      @comment = assign(:issue_comment, @issue.comments.build)

      @issue.user.destroy
      @issue.reload
    end

    it "renders default user name" do
      render
      assert_select ".issue-user", User.destroyed_name
    end
  end

  context "when comment's user destroyed" do
    let(:user) { Fabricate(:user_worker) }

    before do
      @issue = assign(:issue, Fabricate(:issue))
      @issue_comment = Fabricate(:issue_comment, issue: @issue, user: user)
      @comments = assign(:comments, [@issue_comment])
      @comment = assign(:issue_comment, @issue.comments.build)

      @issue_comment.user.destroy
      @issue_comment.reload
    end

    it "renders default user name" do
      render
      assert_select "#comment-#{@issue_comment.id} .comment-user",
                    User.destroyed_name
    end
  end

  context "issues's task destroyed" do
    before do
      @project = assign(:project, Fabricate(:project, category: @category))
      @issue = Fabricate(:issue, project: @project)
      @task = assign(:task, Fabricate(:task, project: @project, issue: @issue))
      @comment = assign(:issue_comment, @issue.comments.build)
      @comments = assign(:comments, [])

      @task.destroy
      @issue.reload
    end

    it "renders" do
      expect do
        render
      end.not_to raise_error
    end
  end
end
