# frozen_string_literal: true

require "rails_helper"

RSpec.describe "task_subscriptions/index", type: :view do
  User::VALID_EMPLOYEE_TYPES.each do |employee_type|
    let(:first_task) { Fabricate(:task) }
    let(:second_task) { Fabricate(:task) }

    before(:each) do
      assign(:subscribed_tasks, page([first_task, second_task]))
    end

    context "for a #{employee_type}" do
      let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

      before do
        enable_can(view, current_user)
        Fabricate(:task_subscription, task: first_task, user: current_user)
        Fabricate(:task_subscription, task: second_task, user: current_user)
      end

      it "renders a list of subscribed tasks" do
        render

        assert_select "#task-#{first_task.id}"
        assert_select "#task-#{second_task.id}"
      end
    end
  end
end
