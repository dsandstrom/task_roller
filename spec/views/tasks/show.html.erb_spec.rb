# frozen_string_literal: true

require "rails_helper"

RSpec.describe "tasks/show", type: :view do
  before(:each) { @category = assign(:category, Fabricate(:category)) }

  context "when project" do
    before do
      @project = assign(:project, Fabricate(:project, category: @category))
      @task = assign(:task, Fabricate(:task, project: @project))
      @comments = assign(:comments, [])
    end

    it "renders task's summary" do
      render
      assert_select ".task-summary", "Task: #{@task.summary}"
    end

    it "renders task's description" do
      render
      assert_select ".task-description", @task.description
    end

    context "task belongs to an issue" do
      let(:issue) { Fabricate(:issue, project: @project) }

      before do
        @task = assign(:task, Fabricate(:task, project: @project, issue: issue))
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
      end

      it "renders them" do
        render
        assert_select "#task-comment-#{task_comment.id}"
      end
    end
  end

  context "when no project" do
    before do
      project = Fabricate(:project, category: @category)
      @task = assign(:task, Fabricate(:task, project: project))
      @comments = assign(:comments, [])
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
      @task.task_type.destroy
      @task.reload
    end

    it "renders summary>" do
      render
      assert_select ".task-summary", "Task: #{@task.summary}"
    end
  end
end
