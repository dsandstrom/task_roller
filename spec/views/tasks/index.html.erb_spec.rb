# frozen_string_literal: true

require "rails_helper"

RSpec.describe "tasks/index", type: :view do
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }

  context "for an admin" do
    let(:admin) { Fabricate(:user_admin) }
    let(:category_tasks_subscription) do
      Fabricate(:category_tasks_subscription, category: category, user: admin)
    end
    let(:project_tasks_subscription) do
      Fabricate(:project_tasks_subscription, project: project, user: admin)
    end

    before { enable_can(view, admin) }

    context "when category" do
      let(:issue) { Fabricate(:issue, project: project) }
      let(:first_project) { Fabricate(:project, category: category) }
      let(:second_project) { Fabricate(:project, category: category) }
      let(:first_task) do
        Fabricate(:task, project: first_project)
      end
      let(:second_task) do
        Fabricate(:task, issue: issue, project: second_project)
      end

      before(:each) do
        assign(:source, category)
        assign(:tasks, page([first_task, second_task]))
        assign(:subscription, category_tasks_subscription)
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

      context "and subscribed to tasks" do
        it "renders unsubscribe link" do
          render

          url = category_tasks_subscription_path(category,
                                                 category_tasks_subscription)
          assert_select "a[data-method='delete'][href='#{url}']"
        end

        it "doesn't render subscribe link" do
          render

          url = category_tasks_subscriptions_path(category)
          expect(rendered).not_to have_link(url)
        end
      end

      context "and not subscribed to tasks" do
        let(:category_tasks_subscription) do
          Fabricate.build(:category_tasks_subscription, category: category,
                                                        user: admin)
        end

        before do
          admin.category_tasks_subscriptions.destroy_all
        end

        it "renders subscribe link" do
          render

          url = category_tasks_subscriptions_path(category)
          assert_select "a[data-method='post'][href='#{url}']"
        end
      end
    end

    context "when project" do
      let(:first_task) { Fabricate(:task, project: project) }
      let(:issue) { Fabricate(:issue, project: project) }
      let(:second_task) { Fabricate(:task, project: project, issue: issue) }

      before(:each) do
        assign(:source, project)
        assign(:tasks, page([first_task, second_task]))
        assign(:subscription, project_tasks_subscription)
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

      context "and subscribed to tasks" do
        it "renders unsubscribe link" do
          render

          url = project_tasks_subscription_path(project,
                                                project_tasks_subscription)
          assert_select "a[data-method='delete'][href='#{url}']"
        end

        it "doesn't render subscribe link" do
          render

          url = project_tasks_subscriptions_path(project)
          expect(rendered).not_to have_link(url)
        end
      end

      context "and not subscribed to tasks" do
        let(:project_tasks_subscription) do
          Fabricate.build(:project_tasks_subscription, project: project,
                                                       user: admin)
        end

        before do
          admin.project_tasks_subscriptions.destroy_all
        end

        it "renders subscribe link" do
          render

          url = project_tasks_subscriptions_path(project)
          assert_select "a[data-method='post'][href='#{url}']"
        end
      end
    end

    context "when user" do
      let(:user) { Fabricate(:user_reviewer) }
      let(:first_task) { Fabricate(:task, user: user) }
      let(:issue) { Fabricate(:issue, user: user) }
      let(:second_task) { Fabricate(:task, user: user, issue: issue) }

      before(:each) do
        assign(:source, user)
        assign(:tasks, page([first_task, second_task]))
        assign(:subscription, project_tasks_subscription)
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
        assign(:tasks, page([first_task, second_task]))
      end

      it "renders a list of tasks" do
        render
        assert_select "#task-#{first_task.id} .task-user", first_task.user.name
        assert_select "#task-#{second_task.id}"
        assert_select "#task-#{second_task.id} .task-user", count: 0
      end
    end
  end

  %w[reviewer].each do |employee_type|
    context "for a #{employee_type}" do
      let(:current_user) { Fabricate("user_#{employee_type}") }
      let(:category_tasks_subscription) do
        Fabricate(:category_tasks_subscription, category: category,
                                                user: current_user)
      end
      let(:project_tasks_subscription) do
        Fabricate(:project_tasks_subscription, project: project,
                                               user: current_user)
      end

      before { enable_can(view, current_user) }

      context "when project" do
        let(:first_task) do
          Fabricate(:task, project: project, user: current_user)
        end
        let(:issue) { Fabricate(:issue, project: project) }
        let(:second_task) { Fabricate(:task, project: project, issue: issue) }

        before(:each) do
          assign(:source, project)
          assign(:tasks, page([first_task, second_task]))
          assign(:subscription, project_tasks_subscription)
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
      let(:category_tasks_subscription) do
        Fabricate(:category_tasks_subscription, category: category,
                                                user: current_user)
      end
      let(:project_tasks_subscription) do
        Fabricate(:project_tasks_subscription, project: project,
                                               user: current_user)
      end

      before { enable_can(view, current_user) }

      context "when project" do
        let(:first_task) do
          Fabricate(:task, project: project, user: current_user)
        end
        let(:issue) { Fabricate(:issue, project: project) }
        let(:second_task) { Fabricate(:task, project: project, issue: issue) }

        before(:each) do
          assign(:source, project)
          assign(:tasks, page([first_task, second_task]))
          assign(:subscription, project_tasks_subscription)
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
