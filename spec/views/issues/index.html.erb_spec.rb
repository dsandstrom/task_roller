# frozen_string_literal: true

require "rails_helper"

RSpec.describe "issues/index", type: :view do
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }

  context "for an admin" do
    let(:admin) { Fabricate(:user_admin) }
    let(:category_issue_subscription) do
      Fabricate(:category_issue_subscription, category: category, user: admin)
    end
    let(:project_issue_subscription) do
      Fabricate(:project_issue_subscription, project: project, user: admin)
    end

    before { enable_can(view, admin) }

    context "when category" do
      let(:first_issue) do
        Fabricate(:issue, project: Fabricate(:project, category: category))
      end
      let(:second_issue) do
        Fabricate(:issue, project: Fabricate(:project, category: category))
      end

      before(:each) do
        assign(:category, category)
        assign(:issues, page([first_issue, second_issue]))
        assign(:subscription, category_issue_subscription)
      end

      it "renders a list of issues" do
        render
        assert_select "#issue-#{first_issue.id}"
        assert_select "#issue-#{second_issue.id}"
      end

      context "and subscribed to issues" do
        it "renders unsubscribe link" do
          render

          url = category_issue_subscription_path(category,
                                                 category_issue_subscription)
          assert_select "a[data-method='delete'][href='#{url}']"
        end

        it "doesn't render subscribe link" do
          render

          url = category_issue_subscriptions_path(category)
          expect(rendered).not_to have_link(url)
        end
      end

      context "and not subscribed to issues" do
        let(:category_issue_subscription) do
          Fabricate.build(:category_issue_subscription, category: category,
                                                        user: admin)
        end

        before do
          admin.category_issue_subscriptions.destroy_all
        end

        it "renders subscribe link" do
          render

          url = category_issue_subscriptions_path(category)
          assert_select "a[data-method='post'][href='#{url}']"
        end
      end
    end

    context "when project" do
      let(:first_issue) { Fabricate(:issue, project: project) }
      let(:second_issue) { Fabricate(:issue, project: project) }

      before(:each) do
        assign(:category, category)
        assign(:project, project)
        assign(:issues, page([first_issue, second_issue]))
        assign(:subscription, project_issue_subscription)
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
        render

        url = new_project_issue_path(project)
        expect(rendered).to have_link(nil, href: url)
      end

      context "and subscribed to issues" do
        it "renders unsubscribe link" do
          render

          url = project_issue_subscription_path(project,
                                                project_issue_subscription)
          assert_select "a[data-method='delete'][href='#{url}']"
        end

        it "doesn't render subscribe link" do
          render

          url = project_issue_subscriptions_path(project)
          expect(rendered).not_to have_link(url)
        end
      end

      context "and not subscribed to issues" do
        let(:project_issue_subscription) do
          Fabricate.build(:project_issue_subscription, project: project,
                                                       user: admin)
        end

        before do
          admin.project_issue_subscriptions.destroy_all
        end

        it "renders subscribe link" do
          render

          url = project_issue_subscriptions_path(project)
          assert_select "a[data-method='post'][href='#{url}']"
        end
      end
    end

    context "when user" do
      let(:user) { Fabricate(:user_reporter) }
      let(:first_issue) { Fabricate(:issue, user: user) }
      let(:second_issue) { Fabricate(:issue, user: user) }

      before(:each) do
        assign(:user, user)
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
        assert_select "#issue-#{second_issue.id} .issue-user",
                      User.destroyed_name
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
      let(:category_issue_subscription) do
        Fabricate(:category_issue_subscription, category: category,
                                                user: current_user)
      end
      let(:project_issue_subscription) do
        Fabricate(:project_issue_subscription, project: project,
                                               user: current_user)
      end

      before { enable_can(view, current_user) }

      context "when project" do
        before(:each) do
          assign(:category, category)
          assign(:project, project)
          assign(:issues, page([first_issue, second_issue]))
          assign(:subscription, project_issue_subscription)
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
          render

          url = new_project_issue_path(project)
          expect(rendered).to have_link(nil, href: url)
        end
      end

      context "when user" do
        context "is them" do
          let(:first_issue) { Fabricate(:issue, user: current_user) }
          let(:second_issue) { Fabricate(:issue, user: current_user) }

          before(:each) do
            assign(:user, current_user)
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
            assign(:user, user)
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
    end
  end
end
