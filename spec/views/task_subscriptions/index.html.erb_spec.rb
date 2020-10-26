# frozen_string_literal: true

require "rails_helper"

RSpec.describe "task_subscriptions/index", type: :view do
  %w[worker reporter].each do |employee_type|
    let(:first_task) { Fabricate(:task) }
    let(:second_task) { Fabricate(:task) }

    before(:each) do
      assign(:tasks, page([first_task, second_task]))
    end

    context "for a #{employee_type}" do
      let(:current_user) { Fabricate("user_#{employee_type}") }

      before { enable_pundit(view, current_user) }

      it "renders a list of subscribed tasks" do
        render

        assert_select "#task-#{first_task.id}"
        assert_select "#task-#{second_task.id}"
      end
    end
  end
end
