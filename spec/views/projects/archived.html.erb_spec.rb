# frozen_string_literal: true

require "rails_helper"

RSpec.describe "projects/archived", type: :view do
  let(:subject) { "projects/archived" }

  before(:each) do
    @category = assign(:category, Fabricate(:invisible_category))
  end

  let(:edit_url) { edit_category_path(@category) }
  let(:new_project_url) { new_category_project_path(@category) }

  context "for an admin" do
    let(:current_user) { Fabricate(:user_admin) }

    before { enable_can(view, current_user) }

    context "when it has no projects" do
      before { @projects = assign(:projects, []) }

      it "renders name" do
        render template: subject, layout: "layouts/application"
        assert_select "h1", @category.name
      end

      it "doesn't render a list of projects" do
        render
        assert_select ".project", count: 0
      end

      it "renders edit category link" do
        render template: subject, layout: "layouts/application"

        expect(rendered).to have_link(nil, href: edit_url)
      end

      it "doesn't render new project link" do
        render template: subject, layout: "layouts/application"

        expect(rendered).not_to have_link(nil, href: new_project_url)
      end
    end

    context "when it has projects, issues, and tasks" do
      let(:project) { Fabricate(:project, category: @category) }

      before { @projects = assign(:projects, [project]) }

      it "renders a list of projects" do
        render
        assert_select "#project-#{project.id}.project"
      end
    end

    context "when category is invisible" do
      let(:project) { Fabricate(:project, category: @category) }

      before do
        @category = assign(:category, Fabricate(:invisible_category))
        @projects = assign(:projects, [project])
      end

      it "doesn't render new project link" do
        render

        expect(rendered).not_to have_link(nil, href: new_project_url)
      end
    end
  end

  context "for a reviewer" do
    let(:current_user) { Fabricate(:user_reviewer) }
    let(:project) { Fabricate(:project, category: @category) }

    before do
      enable_can(view, current_user)

      @projects = assign(:projects, [project])
    end

    context "when category has projects, issues, and tasks" do
      it "renders a list of projects" do
        render
        assert_select "#project-#{project.id}.project"
      end

      it "renders edit category link" do
        render template: subject, layout: "layouts/application"

        expect(rendered).to have_link(nil, href: edit_url)
      end

      it "doesn't render new project link" do
        render template: subject, layout: "layouts/application"

        expect(rendered).not_to have_link(nil, href: new_project_url)
      end
    end

    context "when not subscribed to project" do
      before do
        Fabricate(:project_issues_subscription, project: project)
        Fabricate(:project_tasks_subscription, project: project)
      end

      it "renders subscribe links" do
        render

        issues_url = project_issues_subscriptions_path(project)
        tasks_url = project_tasks_subscriptions_path(project)

        expect(rendered).not_to have_link(nil, href: issues_url)
        expect(rendered).not_to have_link(nil, href: tasks_url)
      end
    end

    context "when subscribed to project" do
      let!(:issues_subscription) do
        Fabricate(:project_issues_subscription, project: project,
                                                user: current_user)
      end
      let!(:tasks_subscription) do
        Fabricate(:project_tasks_subscription, project: project,
                                               user: current_user)
      end

      it "renders unsubscribe links" do
        render

        issues_url =
          project_issues_subscription_path(project, issues_subscription)
        tasks_url = project_tasks_subscription_path(project, tasks_subscription)

        assert_select "a[data-method='delete'][href='#{issues_url}']", count: 0
        assert_select "a[data-method='delete'][href='#{tasks_url}']", count: 0
      end
    end
  end

  %w[worker reporter].each do |employee_type|
    context "for a #{employee_type}" do
      let(:current_user) { Fabricate("user_#{employee_type}") }

      before { enable_can(view, current_user) }

      context "when category has projects, issues, and tasks" do
        let(:project) { Fabricate(:project, category: @category) }

        before { @projects = assign(:projects, [project]) }

        it "renders a list of projects" do
          render
          assert_select "#project-#{project.id}.project"
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
