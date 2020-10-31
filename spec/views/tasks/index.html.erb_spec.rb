# frozen_string_literal: true

require "rails_helper"

# TODO: spec users
RSpec.describe "tasks/index", type: :view do
  context "for an admin" do
    let(:admin) { Fabricate(:user_admin) }

    before { enable_can(view, admin) }

    context "when project" do
      let(:category) { Fabricate(:category) }
      let(:project) { Fabricate(:project, category: category) }
      let(:first_task) { Fabricate(:task, project: project) }
      let(:issue) { Fabricate(:issue, project: project) }
      let(:second_task) { Fabricate(:task, project: project, issue: issue) }

      before(:each) do
        assign(:category, category)
        assign(:project, project)
        assign(:tasks, page([first_task, second_task]))
      end

      it "renders new task link" do
        render

        expect(rendered).to have_link(nil, href: new_project_task_path(project))
      end

      it "renders a list of tasks" do
        render

        assert_select "#task-#{first_task.id}"
        first_url = edit_task_path(first_task)
        expect(rendered).to have_link(nil, href: first_url)
        assert_select "#task-#{second_task.id}"
        second_url = edit_task_path(second_task)
        expect(rendered).to have_link(nil, href: second_url)
        show_url = issue_path(issue)
        expect(rendered).to have_link(nil, href: show_url)
      end
    end

    context "when a task user was destroyed" do
      let(:first_task) { Fabricate(:task) }
      let(:second_task) { Fabricate(:task) }

      before(:each) do
        second_task.user.destroy
        second_task.reload
        assign(:tasks, page([first_task, second_task]))
      end

      it "renders a list of tasks" do
        render
        assert_select "#task-#{first_task.id} .task-user",
                      "Reviewer: #{first_task.user.name}"
        assert_select "#task-#{second_task.id} .task-user",
                      "Reviewer: #{User.destroyed_name}"
      end
    end
  end

  %w[reviewer].each do |employee_type|
    context "for a #{employee_type}" do
      let(:current_user) { Fabricate("user_#{employee_type}") }

      before { enable_can(view, current_user) }

      context "when project" do
        let(:category) { Fabricate(:category) }
        let(:project) { Fabricate(:project, category: category) }
        let(:first_task) do
          Fabricate(:task, project: project, user: current_user)
        end
        let(:issue) { Fabricate(:issue, project: project) }
        let(:second_task) { Fabricate(:task, project: project, issue: issue) }

        before(:each) do
          assign(:category, category)
          assign(:project, project)
          assign(:tasks, page([first_task, second_task]))
        end

        it "renders new task link" do
          render

          expect(rendered)
            .to have_link(nil, href: new_project_task_path(project))
        end

        it "renders a list of tasks" do
          render

          assert_select "#task-#{first_task.id}"
          first_url = edit_task_path(first_task)
          expect(rendered).to have_link(nil, href: first_url)
          assert_select "#task-#{second_task.id}"
          second_url = edit_task_path(second_task)
          expect(rendered).not_to have_link(nil, href: second_url)
          show_url = issue_path(issue)
          expect(rendered).to have_link(nil, href: show_url)
        end
      end
    end
  end

  %w[worker reporter].each do |employee_type|
    context "for a #{employee_type}" do
      let(:current_user) { Fabricate("user_#{employee_type}") }

      before { enable_can(view, current_user) }

      context "when project" do
        let(:category) { Fabricate(:category) }
        let(:project) { Fabricate(:project, category: category) }
        let(:first_task) do
          Fabricate(:task, project: project, user: current_user)
        end
        let(:issue) { Fabricate(:issue, project: project) }
        let(:second_task) { Fabricate(:task, project: project, issue: issue) }

        before(:each) do
          assign(:category, category)
          assign(:project, project)
          assign(:tasks, page([first_task, second_task]))
        end

        it "doesn't render new task link" do
          render

          expect(rendered)
            .not_to have_link(nil, href: new_project_task_path(project))
        end

        it "renders a list of tasks" do
          render

          assert_select "#task-#{first_task.id}"
          first_url = edit_task_path(first_task)
          expect(rendered).to have_link(nil, href: first_url)
          assert_select "#task-#{second_task.id}"
          second_url = edit_task_path(second_task)
          expect(rendered).not_to have_link(nil, href: second_url)
          show_url = issue_path(issue)
          expect(rendered).to have_link(nil, href: show_url)
        end
      end
    end
  end
end
