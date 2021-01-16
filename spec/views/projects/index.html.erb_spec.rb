# frozen_string_literal: true

require "rails_helper"

RSpec.describe "projects/index", type: :view do
  let(:subject) { "projects/index" }
  let(:category) { Fabricate(:category) }

  before(:each) do
    @category = assign(:category, Fabricate(:category))
  end

  let(:edit_url) { edit_category_path(@category) }
  let(:new_project_url) { new_category_project_path(@category) }

  context "for an admin" do
    let(:current_user) { Fabricate(:user_admin) }
    let(:category_issues_subscription) do
      Fabricate(:category_issues_subscription, category: @category,
                                               user: current_user)
    end
    let(:category_tasks_subscription) do
      Fabricate(:category_tasks_subscription, category: @category,
                                              user: current_user)
    end

    before do
      enable_can(view, current_user)

      assign(:issue_subscription, category_issues_subscription)
      assign(:task_subscription, category_tasks_subscription)
    end

    context "when it has no projects" do
      before do
        @projects = assign(:projects, [])
        @issues = assign(:issues, page([]))
        @tasks = assign(:tasks, page([]))
      end

      it "renders name" do
        render template: subject, layout: "layouts/application"
        assert_select "h1", @category.name
      end

      it "doesn't render a list of projects" do
        render
        assert_select ".project", count: 0
      end

      it "doesn't render any issues" do
        render
        assert_select ".issue", count: 0
      end

      it "doesn't render any tasks" do
        render
        assert_select ".task", count: 0
      end

      it "renders edit category link" do
        render template: subject, layout: "layouts/application"

        expect(rendered).to have_link(nil, href: edit_url)
      end

      it "renders new project link" do
        render template: subject, layout: "layouts/application"

        expect(rendered).to have_link(nil, href: new_project_url)
      end
    end

    context "when it has projects, issues, and tasks" do
      let(:project) { Fabricate(:project, category: @category) }
      let(:issue) { Fabricate(:issue, project: project) }
      let(:task) { Fabricate(:task, project: project) }

      before do
        @projects = assign(:projects, [project])
        @issues = assign(:issues, page([issue]))
        @tasks = assign(:tasks, page([task]))
      end

      it "renders a list of projects" do
        render
        assert_select "#project-#{project.id}.project"
      end

      it "renders a list of issues" do
        render
        assert_select "#issue-#{issue.id}.issue"
      end

      it "renders a list of tasks" do
        render
        assert_select "#task-#{task.id}.task"
      end
    end

    context "when it has a task with missing type" do
      let(:project) { Fabricate(:project, category: @category) }
      let(:task) { Fabricate(:task, project: project) }

      before do
        task.task_type.destroy
        task.reload

        @projects = assign(:projects, [project])
        @issues = assign(:issues, page([]))
        @tasks = assign(:tasks, page([task]))

        Fabricate(:task_type)
      end

      it "renders a list of projects" do
        render
        assert_select "#project-#{project.id}.project"
      end

      it "doesn't render issues" do
        render
        assert_select ".issue", count: 0
      end

      it "renders a list of tasks" do
        render
        assert_select "#task-#{task.id}.task"
      end
    end

    context "when it has an issue with missing type" do
      let(:project) { Fabricate(:project, category: @category) }
      let(:issue) { Fabricate(:issue, project: project) }

      before do
        issue.issue_type.destroy
        issue.reload

        @projects = assign(:projects, [project])
        @issues = assign(:issues, page([issue]))
        @tasks = assign(:tasks, page([]))

        Fabricate(:issue_type)
      end

      it "renders a list of projects" do
        render
        assert_select "#project-#{project.id}.project"
      end

      it "renders a list of issues" do
        render
        assert_select "#issue-#{issue.id}.issue"
      end

      it "doesn't render any tasks" do
        render
        assert_select ".task", count: 0
      end
    end

    context "when category is invisible" do
      let(:project) { Fabricate(:project, category: @category) }
      let(:issue) { Fabricate(:issue, project: project) }
      let(:task) { Fabricate(:task, project: project) }

      before do
        @category = assign(:category, Fabricate(:invisible_category))
        @projects = assign(:projects, [project])
        @issues = assign(:issues, page([issue]))
        @tasks = assign(:tasks, page([task]))
      end

      it "doesn't render new project link" do
        render

        expect(rendered).not_to have_link(nil, href: new_project_url)
      end
    end
  end

  context "for a reviewer" do
    let(:current_user) { Fabricate(:user_reviewer) }
    let(:project) { Fabricate(:project, category: category) }
    let(:issue) { Fabricate(:issue, project: project) }
    let(:task) { Fabricate(:task, project: project) }
    let(:category_issues_subscription) do
      Fabricate(:category_issues_subscription, category: @category,
                                               user: current_user)
    end
    let(:category_tasks_subscription) do
      Fabricate(:category_tasks_subscription, category: @category,
                                              user: current_user)
    end

    before do
      enable_can(view, current_user)

      @projects = assign(:projects, [project])
      @issues = assign(:issues, page([issue]))
      @tasks = assign(:tasks, page([task]))
      assign(:issue_subscription, category_issues_subscription)
      assign(:task_subscription, category_tasks_subscription)
    end

    context "when category has projects, issues, and tasks" do
      it "renders a list of projects" do
        render
        assert_select "#project-#{project.id}.project"
      end

      it "renders a list of issues" do
        render
        assert_select "#issue-#{issue.id}.issue"
      end

      it "renders a list of tasks" do
        render
        assert_select "#task-#{task.id}.task"
      end

      it "renders edit category link" do
        render template: subject, layout: "layouts/application"

        expect(rendered).to have_link(nil, href: edit_url)
      end

      it "renders new project link" do
        render template: subject, layout: "layouts/application"

        expect(rendered).to have_link(nil, href: new_project_url)
      end
    end

    context "when subscribed to category issues" do
      it "doesn't render new issue subscription link" do
        render template: subject, layout: "layouts/application"

        url = category_issues_subscriptions_path(@category)
        expect(rendered).not_to have_link(nil, href: url)
      end

      it "renders destroy issue subscription link" do
        render template: subject, layout: "layouts/application"

        url = category_issues_subscription_path(@category,
                                                category_issues_subscription)
        assert_select "a[data-method='delete'][href='#{url}']"
      end
    end

    context "when not subscribed to category issues" do
      let(:category_issues_subscription) do
        Fabricate.build(:category_issues_subscription, category: @category,
                                                       user: current_user)
      end

      before do
        current_user.category_issues_subscriptions.destroy_all
        assign(:issue_subscription, category_issues_subscription)
      end

      it "renders new issue subscription link" do
        render template: subject, layout: "layouts/application"

        url = category_issues_subscriptions_path(@category)
        assert_select "a[href='#{url}'][data-method='post']"
      end
    end

    context "when subscribed to category tasks" do
      it "doesn't render new task subscription link" do
        render template: subject, layout: "layouts/application"

        url = category_tasks_subscriptions_path(@category)
        expect(rendered).not_to have_link(nil, href: url)
      end

      it "renders destroy task subscription link" do
        render template: subject, layout: "layouts/application"

        url = category_tasks_subscription_path(@category,
                                               category_tasks_subscription)
        assert_select "a[data-method='delete'][href='#{url}']"
      end
    end

    context "when not subscribed to category tasks" do
      let(:category_tasks_subscription) do
        Fabricate.build(:category_tasks_subscription, category: @category,
                                                      user: current_user)
      end

      before do
        current_user.category_tasks_subscriptions.destroy_all
        assign(:task_subscription, category_tasks_subscription)
      end

      it "renders new task subscription link" do
        render template: subject, layout: "layouts/application"

        url = category_tasks_subscriptions_path(@category)
        assert_select "a[href='#{url}'][data-method='post']"
      end
    end

    context "when category is invisible" do
      let(:project) { Fabricate(:project, category: @category) }
      let(:issue) { Fabricate(:issue, project: project) }
      let(:task) { Fabricate(:task, project: project) }

      before do
        @category = assign(:category, Fabricate(:invisible_category))
        @projects = assign(:projects, [project])
        @issues = assign(:issues, page([issue]))
        @tasks = assign(:tasks, page([task]))
      end

      it "doesn't render new project link" do
        render template: subject, layout: "layouts/application"

        expect(rendered).not_to have_link(nil, href: new_project_url)
      end
    end
  end

  %w[worker reporter].each do |employee_type|
    context "for a #{employee_type}" do
      let(:current_user) { Fabricate("user_#{employee_type}") }
      let(:category_issues_subscription) do
        Fabricate(:category_issues_subscription, category: @category,
                                                 user: current_user)
      end
      let(:category_tasks_subscription) do
        Fabricate(:category_tasks_subscription, category: @category,
                                                user: current_user)
      end

      before { enable_can(view, current_user) }

      context "when category has projects, issues, and tasks" do
        let(:project) { Fabricate(:project, category: @category) }
        let(:issue) { Fabricate(:issue, project: project) }
        let(:task) { Fabricate(:task, project: project) }

        before do
          @projects = assign(:projects, [project])
          @issues = assign(:issues, page([issue]))
          @tasks = assign(:tasks, page([task]))
          assign(:issue_subscription, category_issues_subscription)
          assign(:task_subscription, category_tasks_subscription)
        end

        it "renders a list of projects" do
          render
          assert_select "#project-#{project.id}.project"
        end

        it "renders a list of issues" do
          render
          assert_select "#issue-#{issue.id}.issue"
        end

        it "renders a list of tasks" do
          render
          assert_select "#task-#{task.id}.task"
        end

        it "doesn't render edit category link" do
          render template: subject, layout: "layouts/application"

          expect(rendered).not_to have_link(nil, href: edit_url)
        end

        it "doesn't render new project link" do
          render template: subject, layout: "layouts/application"

          expect(rendered).not_to have_link(nil, href: new_project_url)
        end
      end
    end
  end
end
