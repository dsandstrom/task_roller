# frozen_string_literal: true

require "rails_helper"

RSpec.describe "tasks/show", type: :view do
  before(:each) { @category = assign(:category, Fabricate(:category)) }

  context "when project" do
    before do
      @project = assign(:project, Fabricate(:project, category: @category))
      @task = assign(:task, Fabricate(:task, project: @project))
      @task_comment = assign(:task_comment, @task.comments.build)
      @comments = assign(:comments, [])
    end

    let(:url) do
      category_project_task_task_comments_url(@category, @project, @task)
    end

    it "renders task's summary" do
      render
      assert_select ".task-summary", "Task: #{@task.summary}"
    end

    it "renders task's description" do
      render
      assert_select ".task-description", @task.description
    end

    it "renders new task_comment form" do
      render

      assert_select "form[action=?][method=?]", url, "post" do
        assert_select "textarea[name=?]", "task_comment[body]"
      end
    end

    context "task belongs to an issue" do
      let(:issue) { Fabricate(:issue, project: @project) }

      before do
        @task = assign(:task, Fabricate(:task, project: @project, issue: issue))
        @task_comment = assign(:task_comment, @task.comments.build)
      end

      it "renders issue" do
        render
        assert_select "#task-issue-#{issue.id}"
      end
    end

    context "task assigned to a user" do
      let(:user) { Fabricate(:user_worker) }

      before do
        @task = assign(:task, Fabricate(:task, assignee_ids: [user.id]))
        @comments = assign(:comments, [])
        @task_comment = assign(:task_comment, @task.comments.build)
      end

      it "renders assignee" do
        render
        assert_select "#task-assignee-#{user.id}"
      end
    end

    context "when task has comments" do
      let(:user) { Fabricate(:user_worker) }
      let(:task_comment) { Fabricate(:task_comment, task: @task) }

      before do
        @task = assign(:task, Fabricate(:task, assignee_ids: [user.id]))
        @comments = assign(:comments, [task_comment])
        @task_comment = assign(:task_comment, @task.comments.build)
      end

      it "renders them" do
        render
        assert_select "#comment-#{task_comment.id}"
      end
    end
  end

  context "when no project" do
    before do
      project = Fabricate(:project, category: @category)
      @task = assign(:task, Fabricate(:task, project: project))
      @comments = assign(:comments, [])
      @task_comment = assign(:task_comment, @task.comments.build)
    end

    it "renders summary>" do
      render
      assert_select ".task-summary", "Task: #{@task.summary}"
    end
  end

  context "when no task_type" do
    before do
      @project = assign(:project, Fabricate(:project, category: @category))
      @task = assign(:task, Fabricate(:task, project: @project))
      @comments = assign(:comments, [])
      @task_comment = assign(:task_comment, @task.comments.build)

      @task.task_type.destroy
      @task.reload
    end

    it "renders summary>" do
      render
      assert_select ".task-summary", "Task: #{@task.summary}"
    end
  end
end
