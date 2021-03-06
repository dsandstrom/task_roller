# frozen_string_literal: true

require "rails_helper"

RSpec.describe "categories/show", type: :view do
  let(:subject) { "categories/show" }
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:first_issue) { Fabricate(:issue, project: project) }
  let(:second_issue) { Fabricate(:issue, project: project) }
  let(:first_task) { Fabricate(:task, project: project) }
  let(:second_task) { Fabricate(:task, project: project) }
  let(:edit_url) { edit_category_path(@category) }

  before(:each) do
    @category = category
    @projects = assign(:projects, [])
    @search_results = assign(:search_results, page([]))
  end

  context "for an admin" do
    let(:current_user) { Fabricate(:user_admin) }

    before { enable_can(view, current_user) }

    context "when tasks and issues" do
      before(:each) do
        issues_and_tasks = [first_issue, first_task, second_issue, second_task]
        @search_results = assign(:search_results, page(issues_and_tasks))
      end

      it "renders name" do
        render template: subject, layout: "layouts/application"
        assert_select "h1", @category.name
      end

      it "renders edit category link" do
        render template: subject, layout: "layouts/application"

        expect(rendered).to have_link(nil, href: edit_url)
      end

      context "when category has an archived project" do
        before { Fabricate(:invisible_project, category: category) }

        it "renders archived projects link" do
          render

          url = archived_category_projects_path(@category)
          expect(rendered).to have_link(nil, href: url)
        end
      end

      context "when category doesn't have an archived project" do
        before { Fabricate(:invisible_project) }

        it "doesn't render archived projects link" do
          render

          url = archived_category_projects_path(@category)
          expect(rendered).not_to have_link(nil, href: url)
        end
      end

      it "renders a list of issues" do
        other_issue =
          Fabricate(:issue, project: Fabricate(:project, category: category))

        render
        assert_select "#issue-#{first_issue.id}", count: 1
        assert_select "#issue-#{second_issue.id}", count: 1
        assert_select "#issue-#{other_issue.id}", count: 0
      end

      it "renders a list of tasks" do
        other_task =
          Fabricate(:task, project: Fabricate(:project, category: category))

        render
        assert_select "#task-#{first_task.id}", count: 1
        assert_select "#task-#{second_task.id}", count: 1
        assert_select "#task-#{other_task.id}", count: 0
      end
    end

    context "when task missing type" do
      before(:each) do
        first_task.task_type.destroy
        first_task.reload
        Fabricate(:task_type)
        @search_results = assign(:search_results, page([first_task]))
      end

      it "renders broken tasks" do
        render
        assert_select "#task-#{first_task.id}", count: 1
      end
    end

    context "when issue missing type" do
      before do
        first_issue.issue_type.destroy
        first_issue.reload
        Fabricate(:issue_type)
        @search_results = assign(:search_results, page([first_issue]))
      end

      it "renders broken issues" do
        render
        assert_select "#issue-#{first_issue.id}", count: 1
      end
    end
  end

  context "for a reviewer" do
    let(:current_user) { Fabricate(:user_reviewer) }

    before { enable_can(view, current_user) }

    context "when tasks and issues" do
      before(:each) do
        issues_and_tasks = [first_issue, first_task, second_issue, second_task]
        @search_results = assign(:search_results, page(issues_and_tasks))
      end

      it "renders edit category link" do
        render template: subject, layout: "layouts/application"

        expect(rendered).to have_link(nil, href: edit_url)
      end

      it "renders a list of issues and tasks " do
        other_issue =
          Fabricate(:issue, project: Fabricate(:project, category: category))

        render
        assert_select "#issue-#{first_issue.id}", count: 1
        assert_select "#issue-#{second_issue.id}", count: 1
        assert_select "#issue-#{other_issue.id}", count: 0
      end

      it "renders a list of tasks" do
        other_task =
          Fabricate(:task, project: Fabricate(:project, category: category))

        render
        assert_select "#task-#{first_task.id}", count: 1
        assert_select "#task-#{second_task.id}", count: 1
        assert_select "#task-#{other_task.id}", count: 0
      end
    end
  end

  %w[worker reporter].each do |employee_type|
    context "for a #{employee_type}" do
      let(:current_user) { Fabricate("user_#{employee_type}") }

      before { enable_can(view, current_user) }

      context "when tasks and issues" do
        before(:each) do
          issues_and_tasks =
            [first_issue, first_task, second_issue, second_task]
          @search_results = assign(:search_results, page(issues_and_tasks))
        end

        it "doesn't render the edit category link" do
          render template: subject, layout: "layouts/application"

          expect(rendered).not_to have_link(nil, href: edit_url)
        end

        it "doesn't render archived projects link" do
          Fabricate(:invisible_project, category: category)

          render

          url = archived_category_projects_path(category)
          expect(rendered).not_to have_link(nil, href: url)
        end

        it "renders a list of issues" do
          other_issue =
            Fabricate(:issue, project: Fabricate(:project, category: category))

          render
          assert_select "#issue-#{first_issue.id}", count: 1
          assert_select "#issue-#{second_issue.id}", count: 1
          assert_select "#issue-#{other_issue.id}", count: 0
        end

        it "renders a list of tasks" do
          other_task =
            Fabricate(:task, project: Fabricate(:project, category: category))

          render
          assert_select "#task-#{first_task.id}", count: 1
          assert_select "#task-#{second_task.id}", count: 1
          assert_select "#task-#{other_task.id}", count: 0
        end
      end
    end
  end
end
