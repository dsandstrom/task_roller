# frozen_string_literal: true

require "rails_helper"

RSpec.describe "task_assignees/new", type: :view do
  let(:task) { Fabricate(:task) }
  let(:path) { task_task_assignees_path(task) }

  let(:url) { task_path(@task) }

  context "for a reviewer" do
    let(:current_user) { Fabricate(:user_reviewer) }

    before do
      enable_can(view, current_user)
      assign(:task, task)
      assign(:task_assignee, TaskAssignee.new(task: task))
    end

    it "renders new task_assignee form" do
      render

      assert_select "form[action=?][method=?]", path, "post"
    end
  end
end
