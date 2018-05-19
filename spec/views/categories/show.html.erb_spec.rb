# frozen_string_literal: true

require "rails_helper"

RSpec.describe "categories/show", type: :view do
  before(:each) { @category = assign(:category, Fabricate(:category)) }

  context "when it has no projects" do
    before do
      @projects = assign(:projects, [])
      @issues = assign(:issues, [])
      @tasks = assign(:issues, [])
    end

    it "renders name" do
      render
      assert_select "h1", @category.name
    end

    it "doesn't render a list of projects" do
      render
      assert_select ".project", count: 0
    end

    it "doesn't render any issues" do
      render
      assert_select ".issue", count: 0
    end

    it "doesn't render any tasks" do
      render
      assert_select ".task", count: 0
    end
  end

  context "when it has projects, issues, and tasks" do
    let(:project) { Fabricate(:project, category: @category) }
    let(:issue) { Fabricate(:issue, project: project) }
    let(:task) { Fabricate(:task, project: project) }

    before do
      @projects = assign(:projects, [project])
      @issues = assign(:issues, [issue])
      @tasks = assign(:tasks, [task])
    end

    it "renders a list of projects" do
      render
      assert_select "#project-#{project.id}.project"
    end

    it "renders a list of issues" do
      render
      assert_select "#issue-#{issue.id}.issue"
    end

    it "renders a list of tasks" do
      render
      assert_select "#task-#{task.id}.task"
    end
  end

  context "when it has a task with missing type" do
    let(:project) { Fabricate(:project, category: @category) }
    let(:task) { Fabricate(:task, project: project) }

    before do
      task.task_type.destroy
      task.reload

      @projects = assign(:projects, [project])
      @issues = assign(:issues, [])
      @tasks = assign(:tasks, [task])

      Fabricate(:task_type)
    end

    it "renders a list of projects" do
      render
      assert_select "#project-#{project.id}.project"
    end

    it "doesn't render issues" do
      render
      assert_select ".issue", count: 0
    end

    it "renders a list of tasks" do
      render
      assert_select "#task-#{task.id}.task"
    end
  end

  context "when it has an issue with missing type" do
    let(:project) { Fabricate(:project, category: @category) }
    let(:issue) { Fabricate(:issue, project: project) }

    before do
      issue.issue_type.destroy
      issue.reload

      @projects = assign(:projects, [project])
      @issues = assign(:issues, [issue])
      @tasks = assign(:tasks, [])

      Fabricate(:issue_type)
    end

    it "renders a list of projects" do
      render
      assert_select "#project-#{project.id}.project"
    end

    it "renders a list of issues" do
      render
      assert_select "#issue-#{issue.id}.issue"
    end

    it "doesn't render any tasks" do
      render
      assert_select ".task", count: 0
    end
  end
end
