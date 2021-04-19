# frozen_string_literal: true

require "rails_helper"

RSpec.describe "issues/index", type: :view do
  let(:subject) { "issues/index" }
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }

  context "for an admin" do
    let(:admin) { Fabricate(:user_admin) }

    before { enable_can(view, admin) }

    context "when category" do
      let(:first_issue) do
        Fabricate(:issue, project: Fabricate(:project, category: category))
      end
      let(:second_issue) do
        Fabricate(:issue, project: Fabricate(:project, category: category))
      end

      before(:each) do
        assign(:source, category)
        assign(:issues, page([first_issue, second_issue]))
      end

      it "renders a list of issues" do
        render
        assert_select "#issue-#{first_issue.id}"
        expect(rendered)
          .to have_link(nil, href: user_issues_path(first_issue.user))
        assert_select "#issue-#{second_issue.id}"
        expect(rendered)
          .to have_link(nil, href: user_issues_path(second_issue.user))
      end

      it "renders issue_notification" do
        Fabricate(:issue_notification, issue: first_issue)
        Fabricate(:issue_notification, issue: second_issue, user: admin)
        Fabricate(:issue_notification, issue: second_issue, user: admin)

        render
        assert_select "#issue-#{first_issue.id} .issue-notification", count: 0
        assert_select "#issue-#{second_issue.id} .issue-notification", count: 1
      end
    end

    context "when project" do
      let(:first_issue) { Fabricate(:issue, project: project) }
      let(:second_issue) { Fabricate(:issue, project: project) }

      before(:each) do
        assign(:source, project)
        assign(:issues, page([first_issue, second_issue]))
      end

      it "renders a list of issues" do
        render

        assert_select "#issue-#{first_issue.id}"
        url = edit_issue_path(first_issue)
        expect(rendered).to have_link(nil, href: url)
        assert_select "#issue-#{second_issue.id}"
        url = edit_issue_path(second_issue)
        expect(rendered).to have_link(nil, href: url)
      end

      it "renders new issue link" do
        render template: subject, layout: "layouts/application"

        url = new_project_issue_path(project)
        expect(rendered).to have_link(nil, href: url)
      end
    end

    context "when user" do
      let(:user) { Fabricate(:user_reporter) }
      let(:first_issue) { Fabricate(:issue, user: user) }
      let(:second_issue) { Fabricate(:issue, user: user) }

      before(:each) do
        assign(:source, user)
        assign(:issues, page([first_issue, second_issue]))
      end

      it "renders a list of issues" do
        render

        assert_select "#issue-#{first_issue.id}"
        url = edit_issue_path(first_issue)
        expect(rendered).to have_link(nil, href: url)
        assert_select "#issue-#{second_issue.id}"
        url = edit_issue_path(second_issue)
        expect(rendered).to have_link(nil, href: url)
      end
    end

    context "when an issue user was destroyed" do
      let(:first_issue) { Fabricate(:issue) }
      let(:second_issue) { Fabricate(:issue) }

      before(:each) do
        second_issue.user.destroy
        second_issue.reload
        assign(:issues, page([first_issue, second_issue]))
      end

      it "renders a list of issues" do
        render
        assert_select "#issue-#{first_issue.id} .issue-user",
                      first_issue.user.name
        assert_select "#issue-#{second_issue.id}"
        assert_select "#issue-#{second_issue.id} .issue-user",
                      User.destroyed_name
      end
    end

    context "when an issue user was cancelled" do
      let(:first_issue) { Fabricate(:issue) }
      let(:second_issue) { Fabricate(:issue) }

      before(:each) do
        second_issue.user.update employee_type: nil
        second_issue.reload
        assign(:issues, page([first_issue, second_issue]))
      end

      it "renders a list of issues" do
        render
        assert_select "#issue-#{first_issue.id} .issue-user",
                      first_issue.user.name
        assert_select "#issue-#{second_issue.id}"
        assert_select "#issue-#{second_issue.id} .issue-user",
                      second_issue.user.name
        expect(rendered)
          .to have_link(nil, href: user_issues_path(second_issue.user))
      end
    end
  end

  %w[reviewer worker reporter].each do |employee_type|
    context "for a #{employee_type}" do
      let(:current_user) { Fabricate("user_#{employee_type}") }
      let(:first_issue) do
        Fabricate(:issue, project: project, user: current_user)
      end
      let(:second_issue) { Fabricate(:issue, project: project) }

      before { enable_can(view, current_user) }

      context "when project" do
        before(:each) do
          assign(:source, project)
          assign(:issues, page([first_issue, second_issue]))
        end

        it "renders a list of issues" do
          render

          assert_select "#issue-#{first_issue.id}"
          url = edit_issue_path(first_issue)
          expect(rendered).to have_link(nil, href: url)
          assert_select "#issue-#{second_issue.id}"
          url = edit_issue_path(second_issue)
          expect(rendered).not_to have_link(nil, href: url)
        end

        it "renders new issue link" do
          render template: subject, layout: "layouts/application"

          url = new_project_issue_path(project)
          expect(rendered).to have_link(nil, href: url)
        end

        it "renders issue_notification" do
          Fabricate(:issue_notification, issue: first_issue)
          Fabricate(:issue_notification, issue: second_issue,
                                         user: current_user)

          render
          assert_select "#issue-#{first_issue.id} .issue-notification", count: 0
          assert_select "#issue-#{second_issue.id} .issue-notification"
        end
      end

      context "when user" do
        context "is them" do
          let(:first_issue) { Fabricate(:issue, user: current_user) }
          let(:second_issue) { Fabricate(:issue, user: current_user) }

          before(:each) do
            assign(:source, current_user)
            assign(:issues, page([first_issue, second_issue]))
          end

          it "renders a list of issues" do
            render

            assert_select "#issue-#{first_issue.id}"
            url = edit_issue_path(first_issue)
            expect(rendered).to have_link(nil, href: url)
            assert_select "#issue-#{second_issue.id}"
            url = edit_issue_path(second_issue)
            expect(rendered).to have_link(nil, href: url)
          end
        end

        context "someone else" do
          let(:user) { Fabricate(:user_reporter) }
          let(:first_issue) { Fabricate(:issue, user: user) }
          let(:second_issue) { Fabricate(:issue, user: user) }

          before(:each) do
            assign(:source, user)
            assign(:issues, page([first_issue, second_issue]))
          end

          it "renders a list of issues" do
            render

            assert_select "#issue-#{first_issue.id}"
            url = edit_issue_path(first_issue)
            expect(rendered).not_to have_link(nil, href: url)
            assert_select "#issue-#{second_issue.id}"
            url = edit_issue_path(second_issue)
            expect(rendered).not_to have_link(nil, href: url)
          end
        end
      end

      context "when an issue user was cancelled" do
        let(:first_issue) { Fabricate(:issue) }
        let(:second_issue) { Fabricate(:issue) }

        before(:each) do
          second_issue.user.update employee_type: nil
          second_issue.reload
          assign(:issues, page([first_issue, second_issue]))
        end

        it "renders a list of issues" do
          render
          assert_select "#issue-#{first_issue.id} .issue-user",
                        first_issue.user.name
          assert_select "#issue-#{second_issue.id}"
          assert_select "#issue-#{second_issue.id} .issue-user",
                        second_issue.user.name
          expect(rendered)
            .not_to have_link(nil, href: user_issues_path(second_issue.user))
        end
      end
    end
  end
end
