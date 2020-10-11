# frozen_string_literal: true

require "rails_helper"

RSpec.describe "issues/index", type: :view do
  context "for an admin" do
    let(:admin) { Fabricate(:user_admin) }

    before { enable_pundit(view, admin) }

    context "when no category and project" do
      let(:first_issue) { Fabricate(:issue) }
      let(:second_issue) { Fabricate(:issue) }

      before(:each) { assign(:issues, [first_issue, second_issue]) }

      it "renders a list of issues" do
        render
        assert_select "#issue-#{first_issue.id}"
        assert_select "#issue-#{second_issue.id}"
      end
    end

    context "when only category" do
      let(:category) { Fabricate(:category) }
      let(:first_issue) do
        Fabricate(:issue, project: Fabricate(:project, category: category))
      end
      let(:second_issue) do
        Fabricate(:issue, project: Fabricate(:project, category: category))
      end

      before(:each) do
        assign(:category, category)
        assign(:issues, [first_issue, second_issue])
      end

      it "renders a list of issues" do
        render
        assert_select "#issue-#{first_issue.id}"
        assert_select "#issue-#{second_issue.id}"
      end
    end

    context "when project" do
      let(:category) { Fabricate(:category) }
      let(:project) { Fabricate(:project, category: category) }
      let(:first_issue) { Fabricate(:issue, project: project) }
      let(:second_issue) { Fabricate(:issue, project: project) }

      before(:each) do
        assign(:category, category)
        assign(:project, project)
        assign(:issues, [first_issue, second_issue])
      end

      it "renders a list of issues" do
        render

        assert_select "#issue-#{first_issue.id}"
        url = edit_category_project_issue_path(category, project, first_issue)
        expect(rendered).to have_link(nil, href: url)
        assert_select "#issue-#{second_issue.id}"
        url = edit_category_project_issue_path(category, project, second_issue)
        expect(rendered).to have_link(nil, href: url)
      end

      it "renders new issue link" do
        render

        url = new_category_project_issue_path(category, project)
        expect(rendered).to have_link(nil, href: url)
      end
    end

    context "when an issue user was destroyed" do
      let(:first_issue) { Fabricate(:issue) }
      let(:second_issue) { Fabricate(:issue) }

      before(:each) do
        second_issue.user.destroy
        second_issue.reload
        assign(:issues, [first_issue, second_issue])
      end

      it "renders a list of issues" do
        render
        assert_select "#issue-#{first_issue.id} .issue-user",
                      first_issue.user.name
        assert_select "#issue-#{second_issue.id} .issue-user",
                      User.destroyed_name
      end
    end
  end

  %w[reviewer worker reporter].each do |employee_type|
    context "for a #{employee_type}" do
      let(:current_user) { Fabricate("user_#{employee_type}") }
      let(:category) { Fabricate(:category) }
      let(:project) { Fabricate(:project, category: category) }
      let(:first_issue) do
        Fabricate(:issue, project: project, user: current_user)
      end
      let(:second_issue) { Fabricate(:issue, project: project) }

      before { enable_pundit(view, current_user) }

      before(:each) do
        assign(:category, category)
        assign(:project, project)
        assign(:issues, [first_issue, second_issue])
      end

      it "renders a list of issues" do
        render

        assert_select "#issue-#{first_issue.id}"
        url = edit_category_project_issue_path(category, project, first_issue)
        expect(rendered).to have_link(nil, href: url)
        assert_select "#issue-#{second_issue.id}"
        url = edit_category_project_issue_path(category, project, second_issue)
        expect(rendered).not_to have_link(nil, href: url)
      end

      it "renders new issue link" do
        render

        url = new_category_project_issue_path(category, project)
        expect(rendered).to have_link(nil, href: url)
      end
    end
  end
end
