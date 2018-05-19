# frozen_string_literal: true

require "rails_helper"

RSpec.describe "projects/show", type: :view do
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:first_issue) { Fabricate(:issue, project: project) }
  let(:second_issue) { Fabricate(:issue, project: project) }
  let(:first_task) { Fabricate(:task, project: project) }
  let(:second_task) { Fabricate(:task, project: project) }

  before(:each) do
    @category = category
    @project = project
    @issues = [first_issue, second_issue]
    @tasks = [first_task, second_task]
  end

  it "renders name" do
    render
    assert_select "h1", @project.name
  end

  it "renders a list of issues" do
    other_issue =
      Fabricate(:issue, project: Fabricate(:project, category: category))

    render
    assert_select "#issue-#{first_issue.id}", count: 1
    assert_select "#issue-#{second_issue.id}", count: 1
    assert_select "#issue-#{other_issue.id}", count: 0
  end

  it "renders a list of tasks" do
    other_task =
      Fabricate(:task, project: Fabricate(:project, category: category))

    render
    assert_select "#task-#{first_task.id}", count: 1
    assert_select "#task-#{second_task.id}", count: 1
    assert_select "#task-#{other_task.id}", count: 0
  end
end
