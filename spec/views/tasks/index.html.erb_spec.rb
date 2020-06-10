# frozen_string_literal: true

require "rails_helper"

RSpec.describe "tasks/index", type: :view do
  context "when no category and project" do
    let(:first_task) { Fabricate(:task) }
    let(:second_task) { Fabricate(:task) }

    before(:each) { assign(:tasks, [first_task, second_task]) }

    it "renders a list of tasks" do
      render
      assert_select "#task-#{first_task.id}"
      assert_select "#task-#{second_task.id}"
    end
  end

  context "when only category" do
    let(:category) { Fabricate(:category) }
    let(:first_task) do
      Fabricate(:task, project: Fabricate(:project, category: category))
    end
    let(:second_task) do
      Fabricate(:task, project: Fabricate(:project, category: category))
    end

    before(:each) do
      assign(:category, category)
      assign(:tasks, [first_task, second_task])
    end

    it "renders a list of tasks" do
      render
      assert_select "#task-#{first_task.id}"
      assert_select "#task-#{second_task.id}"
    end
  end

  context "when project" do
    let(:category) { Fabricate(:category) }
    let(:project) { Fabricate(:project) }
    let(:first_task) { Fabricate(:task, project: project) }
    let(:second_task) { Fabricate(:task, project: project) }

    before(:each) do
      assign(:category, category)
      assign(:project, project)
      assign(:tasks, [first_task, second_task])
    end

    it "renders a list of tasks" do
      render
      assert_select "#task-#{first_task.id}"
      assert_select "#task-#{second_task.id}"
    end
  end

  context "when a task user was destroyed" do
    let(:first_task) { Fabricate(:task) }
    let(:second_task) { Fabricate(:task) }

    before(:each) do
      second_task.user.destroy
      second_task.reload
      assign(:tasks, [first_task, second_task])
    end

    it "renders a list of tasks" do
      render
      assert_select "#task-#{first_task.id} .task-user",
                    first_task.user.name
      assert_select "#task-#{second_task.id} .task-user",
                    User.destroyed_name
    end
  end
end
