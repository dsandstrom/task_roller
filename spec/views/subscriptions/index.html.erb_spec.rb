# frozen_string_literal: true

require "rails_helper"

RSpec.describe "subscriptions/index", type: :view do
  let(:user_reporter) { Fabricate(:user_reporter) }

  User::VALID_EMPLOYEE_TYPES.each do |employee_type|
    context "for a #{employee_type}" do
      let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
      let(:issue) { Fabricate(:issue, user: current_user) }
      let(:task) { Fabricate(:task, user: current_user) }
      let(:assignment) { Fabricate(:task) }

      before do
        enable_can(view, current_user)

        Fabricate(:task_assignee, task: assignment, assignee: current_user)

        assign(:unresolved_issues, [issue])
        assign(:active_assignments, [assignment])
        assign(:open_tasks, [task])
      end

      it "renders a list of the their unresolved issues" do
        render

        assert_select "#issue-#{issue.id}"
        expect(rendered).to have_link(nil, href: issue_path(issue))
      end

      it "renders a list of the their assigned tasks" do
        render

        assert_select "#task-#{assignment.id}"
        expect(rendered).to have_link(nil, href: task_path(assignment))
      end

      it "renders a list of their created tasks" do
        render

        assert_select "#task-#{task.id}"
        expect(rendered).to have_link(nil, href: task_path(task))
      end
    end
  end
end
