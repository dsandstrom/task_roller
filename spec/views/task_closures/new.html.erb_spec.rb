# frozen_string_literal: true

require "rails_helper"

RSpec.describe "task_closures/new", type: :view do
  let(:task) { Fabricate(:task) }
  let(:path) { task_closures_path(task) }

  context "for an admin" do
    let(:current_user) { Fabricate(:user_admin) }

    before(:each) do
      enable_can(view, current_user)
      assign(:task, task)
      assign(:task_closure, TaskClosure.new(task: task))
    end

    it "renders new task_closure form" do
      render

      assert_select "form[action=?][method=?]", path, "post"
    end
  end
end
