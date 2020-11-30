# frozen_string_literal: true

require "rails_helper"

RSpec.describe "move_tasks/edit", type: :view do
  before(:each) do
    @task = assign(:task, Fabricate(:task))
  end

  context "for a reviewer" do
    let(:current_user) { Fabricate(:user_reviewer) }

    before { enable_can(view, current_user) }

    it "renders move_task form" do
      render

      url = move_task_path(@task)
      assert_select "form[action=?]", url do
        assert_select "select[name=?]", "task[project_id]"
      end
    end
  end
end
