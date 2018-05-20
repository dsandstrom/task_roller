# frozen_string_literal: true

require "rails_helper"

RSpec.describe "tasks/show", type: :view do
  before(:each) { @category = assign(:category, Fabricate(:category)) }

  context "when project" do
    before do
      @project = assign(:project, Fabricate(:project, category: @category))
      @task = assign(:task, Fabricate(:task, project: @project))
    end

    it "renders summary>" do
      render
      assert_select ".task-summary", "Task: #{@task.summary}"
    end

    context "task belongs to an issue" do
      let(:issue) { Fabricate(:issue, project: @project) }

      before do
        @task = assign(:task, Fabricate(:task, project: @project, issue: issue))
      end

      it "renders summary>" do
        render
        assert_select "#task-issue-#{issue.id}"
      end
    end
  end

  context "when no project" do
    before do
      project = Fabricate(:project, category: @category)
      @task = assign(:task, Fabricate(:task, project: project))
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
      @task.task_type.destroy
      @task.reload
    end

    it "renders summary>" do
      render
      assert_select ".task-summary", "Task: #{@task.summary}"
    end
  end
end
