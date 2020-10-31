# frozen_string_literal: true

require "rails_helper"

RSpec.describe "projects/show", type: :view do
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:first_issue) { Fabricate(:issue, project: project) }
  let(:second_issue) { Fabricate(:issue, project: project) }
  let(:first_task) { Fabricate(:task, project: project) }
  let(:second_task) { Fabricate(:task, project: project) }
  let(:edit_url) { edit_project_path(@project) }

  before(:each) do
    @category = category
    @project = project
  end

  context "for an admin" do
    let(:current_user) { Fabricate(:user_admin) }

    before { enable_can(view, current_user) }

    context "when tasks and issues" do
      before(:each) do
        @issues = [first_issue, second_issue]
        @tasks = [first_task, second_task]
      end

      it "renders name" do
        render
        assert_select "h1", @project.name
      end

      it "renders edit project link" do
        render

        expect(rendered).to have_link(nil, href: edit_url)
      end

      it "renders new issue link" do
        render

        url = new_project_issue_path(@project)
        expect(rendered).to have_link(nil, href: url)
      end

      it "renders new task link" do
        render

        url = new_project_task_path(@project)
        expect(rendered).to have_link(nil, href: url)
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
        @issues = []
        @tasks = [first_task]
        Fabricate(:task_type)
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
        @issues = [first_issue]
        @tasks = []
        Fabricate(:issue_type)
      end

      it "renders broken issues" do
        render
        assert_select "#issue-#{first_issue.id}", count: 1
      end
    end
  end

  context "for an reviewer" do
    let(:current_user) { Fabricate(:user_reviewer) }

    before { enable_can(view, current_user) }

    context "when tasks and issues" do
      before(:each) do
        @issues = [first_issue, second_issue]
        @tasks = [first_task, second_task]
      end

      it "renders edit project link" do
        render

        expect(rendered).to have_link(nil, href: edit_url)
      end

      it "renders new issue link" do
        render

        url = new_project_issue_path(@project)
        expect(rendered).to have_link(nil, href: url)
      end

      it "renders new task link" do
        render

        url = new_project_task_path(@project)
        expect(rendered).to have_link(nil, href: url)
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

  %w[worker reporter].each do |employee_type|
    context "for a #{employee_type}" do
      let(:current_user) { Fabricate("user_#{employee_type}") }

      before { enable_can(view, current_user) }

      context "when tasks and issues" do
        before(:each) do
          @issues = [first_issue, second_issue]
          @tasks = [first_task, second_task]
        end

        it "doesn't render the edit project link" do
          render

          expect(rendered).not_to have_link(nil, href: edit_url)
        end

        it "renders new issue link" do
          render

          url = new_project_issue_path(@project)
          expect(rendered).to have_link(nil, href: url)
        end

        it "doesn't render new task link" do
          render

          url = new_project_task_path(@project)
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
