# frozen_string_literal: true

require "rails_helper"

RSpec.describe "users/show", type: :view do
  let(:subject) { "users/show" }
  let(:user_reporter) { Fabricate(:user_reporter) }

  context "for an admin" do
    let(:current_user) { Fabricate(:user_admin) }
    let(:issue) { Fabricate(:issue, user: user_reporter) }
    let(:task) { Fabricate(:task, user: user_reporter) }
    let(:assignment) { Fabricate(:task) }

    before do
      enable_can(view, current_user)
      Fabricate(:task_assignee, task: assignment, assignee: user_reporter)
      @user = assign(:user, user_reporter)
      assign(:unresolved_issues, [issue])
      assign(:active_assignments, [assignment])
      assign(:open_tasks, [task])
    end

    it "renders attributes in #user-detail-{@user.id}" do
      render template: subject, layout: "layouts/application"
      expect(rendered).to match(/id="user-detail-#{@user.id}"/)
      expect(rendered).to have_link(nil, href: edit_user_path(@user))
    end

    it "renders a list of the requested user's unresolved issues" do
      render

      assert_select "#issue-#{issue.id}"
      expect(rendered).to have_link(nil, href: issue_path(issue))
    end

    it "renders a list of the requested user's assigned tasks" do
      render

      assert_select "#task-#{assignment.id}"
      expect(rendered).to have_link(nil, href: task_path(assignment))
    end

    it "renders a list of the requested user's created tasks" do
      render

      assert_select "#task-#{task.id}"
      expect(rendered).to have_link(nil, href: task_path(task))
    end
  end

  %w[reviewer worker reporter].each do |employee_type|
    context "for a #{employee_type}" do
      let(:current_user) { Fabricate("user_#{employee_type}") }

      before { enable_can(view, current_user) }

      context "when someone else" do
        let(:issue) { Fabricate(:issue, user: user_reporter) }
        let(:task) { Fabricate(:task, user: user_reporter) }
        let(:assignment) { Fabricate(:task) }

        before do
          Fabricate(:task_assignee, task: assignment, assignee: user_reporter)
          @user = assign(:user, user_reporter)
          assign(:unresolved_issues, [issue])
          assign(:active_assignments, [assignment])
          assign(:open_tasks, [task])
        end

        it "renders attributes in #user-detail-{@user.id}" do
          render template: subject, layout: "layouts/application"
          expect(rendered).to match(/id="user-detail-#{@user.id}"/)
          expect(rendered).not_to have_link(nil, href: edit_user_path(@user))
        end

        it "renders a list of the requested user's unresolved issues" do
          render

          assert_select "#issue-#{issue.id}"
          expect(rendered).to have_link(nil, href: issue_path(issue))
        end

        it "renders a list of the requested user's assigned tasks" do
          render

          assert_select "#task-#{assignment.id}"
          expect(rendered).to have_link(nil, href: task_path(assignment))
        end

        it "renders a list of the requested user's created tasks" do
          render

          assert_select "#task-#{task.id}"
          expect(rendered).to have_link(nil, href: task_path(task))
        end
      end

      context "when them" do
        let(:issue) { Fabricate(:issue, user: current_user) }
        let(:task) { Fabricate(:task, user: current_user) }
        let(:assignment) { Fabricate(:task) }

        before do
          Fabricate(:task_assignee, task: assignment, assignee: current_user)
          @user = assign(:user, current_user)
          assign(:unresolved_issues, [issue])
          assign(:active_assignments, [assignment])
          assign(:open_tasks, [task])
        end

        it "renders attributes in #user-detail-{@user.id}" do
          render template: subject, layout: "layouts/application"
          expect(rendered).to match(/id="user-detail-#{@user.id}"/)
          expect(rendered).to have_link(nil, href: edit_user_path(@user))
        end

        it "renders a list of the requested user's unresolved issues" do
          render

          assert_select "#issue-#{issue.id}"
          expect(rendered).to have_link(nil, href: issue_path(issue))
        end

        it "renders a list of the requested user's assigned tasks" do
          render

          assert_select "#task-#{assignment.id}"
          expect(rendered).to have_link(nil, href: task_path(assignment))
        end

        it "renders a list of the requested user's created tasks" do
          render

          assert_select "#task-#{task.id}"
          expect(rendered).to have_link(nil, href: task_path(task))
        end
      end
    end
  end
end
