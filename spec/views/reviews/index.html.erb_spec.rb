require "rails_helper"

RSpec.describe "reviews/index", type: :view do
  %w[admin reviewer worker reporter].each do |employee_type|
    context "for a #{employee_type}" do
      let(:current_user) { Fabricate("user_#{employee_type}") }
      let(:user) { Fabricate(:user_reviewer) }
      let(:task) { Fabricate(:approved_task, reviewer: user) }

      before do
        enable_can(view, current_user)
        assign(:user, user)
        assign(:tasks, page([task]))
      end

      it "renders a list of tasks" do
        render
        assert_select "#task-#{task.id}"
      end
    end
  end
end
