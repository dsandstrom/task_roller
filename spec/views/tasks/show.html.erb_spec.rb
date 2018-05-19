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
      assert_select ".task-summary", @task.summary
    end
  end

  context "when no project" do
    before do
      project = Fabricate(:project, category: @category)
      @task = assign(:task, Fabricate(:task, project: project))
    end

    it "renders summary>" do
      render
      assert_select ".task-summary", @task.summary
    end
  end
end
