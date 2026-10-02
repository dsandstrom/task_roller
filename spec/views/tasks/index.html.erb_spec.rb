require "rails_helper"

RSpec.describe "tasks/index", type: :view do
  let(:subject) { "tasks/index" }
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }

  context "for an admin" do
    let(:admin) { Fabricate(:user_admin) }

    before do
      enable_can(view, admin)
      controller.extra_params = { user_id: admin.id }
    end

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
      end

      it "renders a list of tasks" do
        render

        assert_select "#task-#{first_task.id}"
        first_url = edit_task_path(first_task)
        expect(rendered).to have_link(nil, href: first_url)
        assert_select "#task-#{second_task.id}"
        second_url = edit_task_path(second_task)
        expect(rendered).to have_link(nil, href: second_url)
        issue_url = task_issue_previews_path(second_task)
        expect(rendered).to have_link(nil, href: issue_url)
      end

      it "renders task_notification" do
        Fabricate(:task_notification, task: first_task)
        Fabricate(:task_notification, task: second_task, user: admin)
        Fabricate(:task_notification, task: second_task, user: admin)

        render
        assert_select "#task-#{first_task.id} .task-notification", count: 0
        assert_select "#task-#{second_task.id} .task-notification", count: 1
      end
    end

    context "when project" do
      let(:first_task) { Fabricate(:task, project: project) }
      let(:issue) { Fabricate(:issue, project: project) }
      let(:second_task) { Fabricate(:task, project: project, issue: issue) }

      before(:each) do
        assign(:source, project)
        assign(:tasks, page([first_task, second_task]))
      end

      it "renders new task link" do
        render template: subject, layout: "layouts/application"

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
        issue_url = task_issue_previews_path(second_task)
        expect(rendered).to have_link(nil, href: issue_url)
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
      end

      it "renders a list of tasks" do
        render

        assert_select "#task-#{first_task.id}"
        assert_select "#task-#{second_task.id}"
        expect(rendered)
          .to have_link(nil, href: user_tasks_path(first_task.user))
        expect(rendered)
          .to have_link(nil, href: user_tasks_path(second_task.user))
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
        assert_select "#task-#{second_task.id} .task-user", User.destroyed_name
      end
    end

    context "when a task user was cancelled" do
      let(:first_task) { Fabricate(:task) }
      let(:second_task) { Fabricate(:task) }

      before(:each) do
        second_task.user.update employee_type: nil
        second_task.reload
        assign(:tasks, page([first_task, second_task]))
      end

      it "renders a list of tasks" do
        render
        assert_select "#task-#{first_task.id} .task-user", first_task.user.name
        assert_select "#task-#{second_task.id} .task-user",
                      second_task.user.name
        expect(rendered)
          .to have_link(nil, href: user_tasks_path(second_task.user))
      end
    end
  end

  context "for a reviewer" do
    let(:current_user) { Fabricate(:user_reviewer) }

    before do
      enable_can(view, current_user)
    end

    context "for a user's tasks" do
      let(:first_task) do
        Fabricate(:task, project: project, user: current_user)
      end

      let(:issue) { Fabricate(:issue, project: project) }
      let(:second_task) { Fabricate(:task, project: project, issue: issue) }

      before(:each) do
        assign(:source, project)
        assign(:tasks, page([first_task, second_task]))
        controller.extra_params = { user_id: current_user.id }
      end

      it "renders new task link" do
        render template: subject, layout: "layouts/application"

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
        issue_url = task_issue_previews_path(second_task)
        expect(rendered).to have_link(nil, href: issue_url)
      end

      it "renders task_notification" do
        Fabricate(:task_notification, task: first_task)
        Fabricate(:task_notification, task: second_task, user: current_user)

        render
        assert_select "#task-#{first_task.id} .task-notification", count: 0
        assert_select "#task-#{second_task.id} .task-notification"
      end
    end

    context "when a task user was cancelled" do
      let(:first_task) { Fabricate(:task) }
      let(:second_task) { Fabricate(:task) }

      before(:each) do
        second_task.user.update employee_type: nil
        second_task.reload
        assign(:tasks, page([first_task, second_task]))
      end

      it "renders a list of tasks" do
        render
        assert_select "#task-#{first_task.id} .task-user",
                      first_task.user.name
        assert_select "#task-#{second_task.id} .task-user",
                      second_task.user.name
        expect(rendered)
          .not_to have_link(nil, href: user_tasks_path(second_task.user))
      end
    end

    context "for a project's tasks" do
      let(:task_type) { Fabricate(:task_type) }
      let(:first_task) do
        Fabricate(:task, project: project, user: current_user,
                         task_type: task_type)
      end

      let(:issue) { Fabricate(:issue, project: project) }
      let(:second_task) { Fabricate(:task, project: project, issue: issue) }

      let(:url) { project_tasks_path(project, task_type_id: task_type.id) }

      before(:each) do
        assign(:source, project)
        assign(:tasks, page([first_task, second_task]))
        controller.extra_params =
          { project_id: project.id, task_type_id: task_type.id }
      end

      it "renders a list of tasks" do
        render

        assert_select "#task-#{first_task.id}"
        first_url = edit_task_path(first_task)
        expect(rendered).to have_link(nil, href: first_url)
        assert_select "#task-#{second_task.id}"
        second_url = edit_task_path(second_task)
        expect(rendered).not_to have_link(nil, href: second_url)
        issue_url = task_issue_previews_path(second_task)
        expect(rendered).to have_link(nil, href: issue_url)
      end

      it "renders filter form" do
        render

        assert_select "form[action=?][method=?]", url, "get" do
          assert_select "input[name=?]", "query"
          assert_select "input[name=?]", "order"
          assert_select "input[name=?]", "task_status"
          assert_select "input[name=?]", "task_type_id"
        end
      end

      context "when search subscription doesn't exist" do
        let(:search_subscription) do
          Fabricate.build(:search_subscription,
                          user: current_user,
                          include_issues: false, include_tasks: true,
                          term: nil, project_id: project.id,
                          task_type_id: task_type.id)
        end

        before do
          assign(:search_subscription, search_subscription)
        end

        it "renders new SearchSubscription form" do
          render

          assert_select "form[action=?][method=?]",
                        search_subscriptions_path, "post" do
            assert_select "input[type=hidden][name=?]",
                          "search_subscription[category_id]"
            assert_select "input[type=hidden][name=?][value=?]",
                          "search_subscription[project_id]", project.id
            assert_select "input[type=hidden][name=?]",
                          "search_subscription[source_user_id]"
            assert_select "input[type=hidden][name=?]",
                          "search_subscription[term]"
            assert_select "input[type=hidden][name=?][value=?]",
                          "search_subscription[include_issues]", "false"
            assert_select "input[type=hidden][name=?][value=?]",
                          "search_subscription[include_tasks]", "true"
            assert_select "input[type=hidden][name=?]",
                          "search_subscription[issue_type_id]"
            assert_select "input[type=hidden][name=?][value=?]",
                          "search_subscription[task_type_id]", task_type.id
            assert_select "input[type=hidden][name=?]",
                          "search_subscription[issue_status]"
            assert_select "input[type=hidden][name=?]",
                          "search_subscription[task_status]"
          end
        end

        it "renders link to all search_subscriptions" do
          render

          expect(rendered).to have_link(nil, href: search_subscriptions_path)
        end
      end

      context "when active search subscription exists" do
        let(:search_subscription) do
          Fabricate(:search_subscription, user: current_user,
                                          include_issues: false,
                                          include_tasks: true,
                                          term: nil, project_id: project.id,
                                          task_type_id: first_task.task_type.id)
        end

        before do
          assign(:search_subscription, search_subscription)
        end

        it "doesn't render new SearchSubscription form" do
          render

          assert_select "form[action=?][method=?]",
                        search_subscriptions_path, "post", count: 0
        end

        it "renders search subscription unsubscribe form" do
          render

          assert_select "form[action=?][method=?]",
                        toggle_search_subscription_path(search_subscription),
                        "post"
        end
      end

      context "when inactive search subscription exists" do
        let(:search_subscription) do
          Fabricate(:inactive_search_subscription,
                    user: current_user, include_issues: false,
                    include_tasks: true, term: nil, project_id: project.id,
                    task_type_id: first_task.task_type.id)
        end

        before do
          assign(:search_subscription, search_subscription)
        end

        it "doesn't render new SearchSubscription form" do
          render

          assert_select "form[action=?][method=?]",
                        search_subscriptions_path, "post", count: 0
        end

        it "renders search subscription unsubscribe form" do
          render

          assert_select "form[action=?][method=?]",
                        toggle_search_subscription_path(search_subscription),
                        "post"
        end
      end
    end
  end

  %w[worker reporter].each do |employee_type|
    context "for a #{employee_type}" do
      let(:current_user) { Fabricate("user_#{employee_type}") }

      before do
        enable_can(view, current_user)
        controller.extra_params = { user_id: current_user.id }
      end

      context "for user's tasks" do
        let(:first_task) do
          Fabricate(:task, project: project, user: current_user)
        end
        let(:issue) { Fabricate(:issue, project: project) }
        let(:second_task) { Fabricate(:task, project: project, issue: issue) }

        before(:each) do
          assign(:source, project)
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
          expect(rendered).not_to have_link(nil, href: first_url)
          assert_select "#task-#{second_task.id}"
          second_url = edit_task_path(second_task)
          expect(rendered).not_to have_link(nil, href: second_url)
          issue_url = task_issue_previews_path(second_task)
          expect(rendered).to have_link(nil, href: issue_url)
        end

        it "renders task_notification" do
          Fabricate(:task_notification, task: first_task)
          Fabricate(:task_notification, task: second_task, user: current_user)

          render
          assert_select "#task-#{first_task.id} .task-notification", count: 0
          assert_select "#task-#{second_task.id} .task-notification"
        end
      end

      context "when a task user was cancelled" do
        let(:first_task) { Fabricate(:task) }
        let(:second_task) { Fabricate(:task) }

        before(:each) do
          second_task.user.update employee_type: nil
          second_task.reload
          assign(:tasks, page([first_task, second_task]))
        end

        it "renders a list of tasks" do
          render
          assert_select "#task-#{first_task.id} .task-user",
                        first_task.user.name
          assert_select "#task-#{second_task.id} .task-user",
                        second_task.user.name
          expect(rendered)
            .not_to have_link(nil, href: user_tasks_path(second_task.user))
        end
      end
    end
  end
end
