# frozen_string_literal: true

require "rails_helper"

RSpec.describe "issues/show", type: :view do
  let(:subject) { "issues/show" }
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:issue) { Fabricate(:issue, project: project) }
  let(:closed_issue) { Fabricate(:closed_issue, project: project) }

  before { @project = project }

  context "for an admin" do
    let(:current_user) { Fabricate(:user_admin) }
    let(:issue_subscription) do
      Fabricate(:issue_subscription, issue: issue, user: current_user)
    end

    before do
      enable_can(view, current_user)
      assign(:duplicates, [])
      assign(:comments, [])
      assign(:subscription, issue_subscription)
      assign(:user, issue.user)
    end

    context "when project" do
      let(:url) { issue_issue_comments_url(@issue) }

      before { @issue = assign(:issue, issue) }

      it "renders issue's heading" do
        render template: subject, layout: "layouts/application"
        assert_select ".issue-heading", @issue.heading
      end

      it "renders issue's description" do
        render
        assert_select ".issue-description main", @issue.description
      end

      it "renders new issue_comment form" do
        render

        assert_select "form[action=?][method=?]", url, "post" do
          assert_select "textarea[name=?]", "issue_comment[body]"
        end
      end

      it "renders edit link" do
        render

        url = edit_issue_path(@issue)
        expect(rendered).to have_link(nil, href: url)
      end

      it "renders new connection link" do
        render

        url = new_issue_connection_path(@issue)
        expect(rendered).to have_link(nil, href: url)
      end

      it "renders new task link" do
        render

        url =
          new_project_task_path(@issue.project, task: { issue_id: @issue.id })
        expect(rendered).to have_link(nil, href: url)
      end

      it "renders move issue link" do
        render
        expect(rendered).to have_link(nil, href: new_issue_move_path(@issue))
      end

      context "and has tasks" do
        it "renders a list of tasks" do
          task = Fabricate(:task, issue: @issue)

          render
          assert_select "#task-#{task.id}"
        end
      end

      context "and has a target_issue_connection" do
        before do
          @target_connection = Fabricate(:issue_connection, target: @issue)
          @duplicates = assign(:duplicates, [@target_connection.source])
        end

        it "renders a list of target_connections" do
          render

          duplicate = @target_connection.source
          url = issue_path(duplicate)
          expect(rendered).to have_link(nil, href: url)
        end
      end
    end

    context "when no project" do
      before do
        @issue = assign(:issue, issue)
        @issue.comments.build

        @issue.update_attribute :project_id, nil
        @issue.reload
      end

      it "renders heading" do
        render template: subject, layout: "layouts/application"
        assert_select ".issue-heading", @issue.heading
      end
    end

    context "when no issue_type" do
      before do
        @issue = assign(:issue, issue)

        @issue.issue_type.destroy
        @issue.reload
      end

      it "renders heading" do
        render template: subject, layout: "layouts/application"
        assert_select ".issue-heading", @issue.heading
      end
    end

    context "when issue user" do
      before do
        @issue = assign(:issue, issue)
        @user = assign(:user, @issue.user)
      end

      it "renders link to user issues" do
        render
        expect(rendered).to have_link(nil, href: user_issues_path(@user))
      end
    end

    context "when issue's user destroyed" do
      before do
        @issue = assign(:issue, issue)
        @user = assign(:user, nil)
      end

      it "renders default user name" do
        render
        assert_select ".issue-user", User.destroyed_name
      end
    end

    context "when comment's user destroyed" do
      let(:user) { Fabricate(:user_worker) }

      before do
        @issue = assign(:issue, issue)
        @issue_comment = Fabricate(:issue_comment, issue: @issue, user: user)
        assign(:comments, [@issue_comment])

        @issue_comment.user.destroy
        @issue_comment.reload
      end

      it "renders default user name" do
        render
        assert_select "#comment-#{@issue_comment.id} .comment-user",
                      User.destroyed_name
      end
    end

    context "issues's task destroyed" do
      before do
        @issue = assign(:issue, issue)
        @task =
          assign(:task, Fabricate(:task, project: @project, issue: @issue))

        @task.destroy
        @issue.reload
      end

      it "renders without errors" do
        expect do
          render
        end.not_to raise_error
      end
    end

    context "when comments" do
      before do
        @issue = assign(:issue, issue)
        @first_comment = Fabricate(:issue_comment, issue: @issue)
        @second_comment = Fabricate(:issue_comment, issue: @issue,
                                                    user: current_user)
        @comments = assign(:comments, [@first_comment, @second_comment])
      end

      it "renders a list of comments" do
        render

        assert_select "#comment-#{@first_comment.id}"
        assert_select "#comment-#{@second_comment.id}"

        first_url = issue_issue_comment_path(@issue, @first_comment)
        first_edit_url = edit_issue_issue_comment_path(@issue, @first_comment)
        second_url = issue_issue_comment_path(@issue, @second_comment)
        second_edit_url = edit_issue_issue_comment_path(@issue, @second_comment)
        expect(rendered).to have_link(nil, href: first_edit_url)
        expect(rendered).to have_link(nil, href: second_edit_url)

        assert_select "a[data-method='delete'][href='#{first_url}']"
        assert_select "a[data-method='delete'][href='#{second_url}']"
      end
    end

    context "when not subscribed to the issue" do
      before do
        @issue = assign(:issue, issue)
        subscription = Fabricate.build(:issue_subscription, issue: @issue,
                                                            user: current_user)
        assign(:subscription, subscription)
      end

      it "renders new issue_subscription link" do
        render
        expect(rendered)
          .to have_link(nil, href: issue_issue_subscriptions_path(@issue))
      end
    end

    context "when subscribed to the issue" do
      before do
        @issue = assign(:issue, issue)
        @subscription = assign(:subscription, issue_subscription)
      end

      it "doesn't render new issue_subscription link" do
        render
        url = issue_issue_subscriptions_path(@issue)
        expect(rendered).not_to have_link(nil, href: url)
      end

      it "renders destroy issue_subscription link" do
        render
        url = issue_issue_subscription_path(@issue, @subscription)
        assert_select "a[data-method='delete'][href='#{url}']"
      end
    end

    context "when issue open" do
      before { @issue = assign(:issue, issue) }

      it "renders close issue link" do
        render

        url = issue_closures_path(@issue)
        assert_select "a[href='#{url}'][data-method='post']"
      end

      it "doesn't render open issue link" do
        render

        url = issue_reopenings_path(@issue)
        expect(rendered).not_to have_link(nil, href: url)
      end
    end

    context "when issue closed with a duplicate" do
      before do
        @issue = assign(:issue, closed_issue)
        issue_connection = Fabricate(:issue_connection, source: @issue)
        @source_connection = assign(:source_connection, issue_connection)
      end

      it "renders source_connection" do
        render

        duplicatee = @source_connection.target
        url = issue_path(duplicatee)
        expect(rendered).to have_link(nil, href: url)
      end

      it "doesn't render new connection link" do
        render

        url = new_issue_connection_path(@issue)
        expect(rendered).not_to have_link(nil, href: url)
      end

      it "renders destroy connection link" do
        render

        url = issue_connection_path(@source_connection)
        assert_select "a[data-method=\"delete\"][href=\"#{url}\"]"
      end

      it "doesn't render close issue link" do
        render

        url = issue_closures_path(@issue)
        expect(rendered).not_to have_link(nil, href: url)
      end

      it "doesn't render open issue link" do
        render

        url = issue_reopenings_path(@issue)
        expect(rendered).not_to have_link(nil, href: url)
      end
    end

    context "when issue closed without a duplicate" do
      before { @issue = assign(:issue, closed_issue) }

      it "doesn't render close issue link" do
        render

        url = issue_closures_path(@issue)
        expect(rendered).not_to have_link(nil, href: url)
      end

      it "renders reopen issue link" do
        render

        url = issue_reopenings_path(@issue)
        assert_select "a[href='#{url}'][data-method='post']"
      end
    end

    context "when issue is resolved" do
      let(:issue) { Fabricate(:closed_issue, project: @project) }

      before do
        @issue = assign(:issue, issue)
        @resolution = Fabricate(:resolution, issue: issue, user: @issue.user)
      end

      it "renders resolution" do
        render

        assert_select "#resolution-history-#{@resolution.id}"
      end

      it "doesn't render disapprove resolution link" do
        render

        url = disapprove_issue_resolutions_path(@issue)
        expect(rendered).not_to have_link(nil, href: url)
      end

      it "doesn't render approve resolution link" do
        render

        url = approve_issue_resolutions_path(@issue)
        expect(rendered).not_to have_link(nil, href: url)
      end

      it "renders destroy resolution link" do
        render

        url = issue_resolution_path(@issue, @resolution)
        assert_select "a[data-method='delete'][href='#{url}']"
      end

      it "doesn't render close issue link" do
        render

        url = issue_closures_path(@issue)
        expect(rendered).not_to have_link(nil, href: url)
      end
    end

    context "when issue is addressed" do
      let(:issue) { Fabricate(:closed_issue, project: @project) }

      before do
        @issue = assign(:issue, issue)
        Fabricate(:approved_task, issue: issue)
      end

      it "doesn't render disapprove resolution link" do
        render

        url = disapprove_issue_resolutions_path(@issue)
        expect(rendered).not_to have_link(nil, href: url)
      end

      it "doesn't render approve resolution link" do
        render

        url = approve_issue_resolutions_path(@issue)
        expect(rendered).not_to have_link(nil, href: url)
      end

      it "renders reopen issue link" do
        render

        url = issue_reopenings_path(@issue)
        assert_select "a[href='#{url}'][data-method='post']"
      end

      it "doesn't render close issue link" do
        render

        url = issue_closures_path(@issue)
        expect(rendered).not_to have_link(nil, href: url)
      end
    end

    context "when issue project is internal" do
      let(:project) { Fabricate(:internal_project, category: category) }
      let(:issue) { Fabricate(:issue, project: project) }
      let(:closed_issue) { Fabricate(:closed_issue, project: project) }

      context "when not subscribed to the issue" do
        before do
          @issue = assign(:issue, issue)
          subscription =
            Fabricate.build(:issue_subscription, issue: @issue,
                                                 user: current_user)
          assign(:subscription, subscription)
        end

        it "renders new issue_subscription link" do
          render
          expect(rendered)
            .to have_link(nil, href: issue_issue_subscriptions_path(@issue))
        end
      end

      context "when subscribed to the issue" do
        before do
          @issue = assign(:issue, issue)
          @subscription = assign(:subscription, issue_subscription)
        end

        it "doesn't render new issue_subscription link" do
          render
          url = issue_issue_subscriptions_path(@issue)
          expect(rendered).not_to have_link(nil, href: url)
        end

        it "renders destroy issue_subscription link" do
          render
          url = issue_issue_subscription_path(@issue, @subscription)
          assert_select "a[data-method='delete'][href='#{url}']"
        end
      end

      context "and open" do
        before { @issue = assign(:issue, issue) }

        it "renders new issue_comment form" do
          render

          url = issue_issue_comments_url(issue)
          assert_select "form[action=?][method=?]", url, "post"
        end

        it "renders edit link" do
          render

          url = edit_issue_path(@issue)
          expect(rendered).to have_link(nil, href: url)
        end

        it "renders new connection link" do
          render

          url = new_issue_connection_path(@issue)
          expect(rendered).to have_link(nil, href: url)
        end

        it "renders new task link" do
          render

          url =
            new_project_task_path(@issue.project, task: { issue_id: @issue.id })
          expect(rendered).to have_link(nil, href: url)
        end

        it "renders close issue link" do
          render

          url = issue_closures_path(@issue)
          assert_select "a[href='#{url}'][data-method='post']"
        end
      end

      context "and closed with a source_connection" do
        let(:issue_connection) { Fabricate(:issue_connection, source: @issue) }

        before do
          @issue = assign(:issue, closed_issue)
          @source_connection = assign(:source_connection, issue_connection)
        end

        it "renders source_connection" do
          render

          duplicatee = @source_connection.target
          url = issue_path(duplicatee)
          expect(rendered).to have_link(nil, href: url)
        end

        it "doesn't render new connection link" do
          render

          url = new_issue_connection_path(@issue)
          expect(rendered).not_to have_link(nil, href: url)
        end

        it "renders destroy connection link" do
          render

          url = issue_connection_path(@source_connection)
          assert_select "a[data-method=\"delete\"][href=\"#{url}\"]"
        end
      end
    end

    context "when issue project is invisible" do
      let(:project) { Fabricate(:invisible_project, category: category) }
      let(:issue) { Fabricate(:issue, project: project) }
      let(:closed_issue) { Fabricate(:closed_issue, project: project) }

      context "and not subscribed to the issue" do
        before do
          @issue = assign(:issue, issue)
          subscription =
            Fabricate.build(:issue_subscription, issue: @issue,
                                                 user: current_user)
          assign(:subscription, subscription)
        end

        it "doesn't render new issue_subscription link" do
          render
          expect(rendered)
            .not_to have_link(nil, href: issue_issue_subscriptions_path(@issue))
        end
      end

      context "and subscribed to the issue" do
        before do
          @issue = assign(:issue, issue)
          @subscription = assign(:subscription, issue_subscription)
        end

        it "doesn't render destroy issue_subscription link" do
          render
          url = issue_issue_subscription_path(@issue, @subscription)
          expect(rendered).not_to have_link(nil, href: url)
        end
      end

      context "and open" do
        before { @issue = assign(:issue, issue) }

        it "doesn't render new issue_comment form" do
          render

          url = issue_issue_comments_url(issue)
          assert_select "form[action=?]", url, count: 0
        end

        it "renders edit link" do
          render

          url = edit_issue_path(@issue)
          expect(rendered).to have_link(nil, href: url)
        end

        it "renders new connection link" do
          render

          url = new_issue_connection_path(@issue)
          expect(rendered).to have_link(nil, href: url)
        end

        it "doesn't render new task link" do
          render

          url =
            new_project_task_path(@issue.project, task: { issue_id: @issue.id })
          expect(rendered).not_to have_link(nil, href: url)
        end

        it "renders close issue link" do
          render

          url = issue_closures_path(@issue)
          assert_select "a[href='#{url}'][data-method='post']"
        end
      end

      context "and closed with a source_connection" do
        let(:issue_connection) { Fabricate(:issue_connection, source: @issue) }

        before do
          @issue = assign(:issue, closed_issue)
          @source_connection = assign(:source_connection, issue_connection)
        end

        it "renders source_connection" do
          render

          duplicatee = @source_connection.target
          url = issue_path(duplicatee)
          expect(rendered).to have_link(nil, href: url)
        end

        it "doesn't render new connection link" do
          render

          url = new_issue_connection_path(@issue)
          expect(rendered).not_to have_link(nil, href: url)
        end

        it "renders destroy connection link" do
          render

          url = issue_connection_path(@source_connection)
          assert_select "a[data-method=\"delete\"][href=\"#{url}\"]"
        end
      end

      context "and is closed with resolution" do
        before do
          @issue = assign(:issue, closed_issue)
          @resolution = Fabricate(:resolution, issue: @issue, user: @issue.user)
        end

        it "renders resolution" do
          render

          assert_select "#resolution-history-#{@resolution.id}"
        end

        it "renders destroy resolution link" do
          render

          url = issue_resolution_path(@issue, @resolution)
          assert_select "a[data-method='delete'][href='#{url}']"
        end

        it "renders reopen issue link" do
          render

          url = issue_reopenings_path(@issue)
          assert_select "a[href='#{url}'][data-method='post']"
        end
      end
    end
  end

  context "for a reviewer" do
    let(:current_user) { Fabricate(:user_reviewer) }
    let(:issue_subscription) do
      Fabricate(:issue_subscription, issue: issue, user: current_user)
    end

    before do
      enable_can(view, current_user)
      assign(:duplicates, [])
      assign(:comments, [])
      assign(:subscription, issue_subscription)
      assign(:user, issue.user)
    end

    context "when someone else's issue" do
      let(:url) { issue_issue_comments_url(@issue) }

      before do
        @issue = assign(:issue, issue)
        @user = assign(:user, @issue.user)
        assign(:issue_comment, @issue.comments.build(user_id: current_user.id))
      end

      it "renders issue's heading" do
        render template: subject, layout: "layouts/application"
        assert_select ".issue-heading", @issue.heading
      end

      it "renders issue's description" do
        render
        assert_select ".issue-description main", @issue.description
      end

      it "renders new issue_comment form" do
        render

        assert_select "form[action=?][method=?]", url, "post" do
          assert_select "textarea[name=?]", "issue_comment[body]"
        end
      end

      it "doesn't render the edit link" do
        render

        url = edit_issue_path(@issue)
        expect(rendered).not_to have_link(nil, href: url)
      end

      it "renders new connection link" do
        render

        url = new_issue_connection_path(@issue)
        expect(rendered).to have_link(nil, href: url)
      end

      it "renders new task link" do
        render

        url =
          new_project_task_path(@issue.project, task: { issue_id: @issue.id })
        expect(rendered).to have_link(nil, href: url)
      end

      it "renders link to issue user's issues" do
        render
        expect(rendered).to have_link(nil, href: user_issues_path(@user))
      end

      it "renders move issue link" do
        render
        expect(rendered).to have_link(nil, href: new_issue_move_path(@issue))
      end
    end

    context "when a source_connection" do
      before do
        @issue = assign(:issue, issue)
        issue_connection = Fabricate(:issue_connection, source: @issue)
        @source_connection = assign(:source_connection, issue_connection)
      end

      it "renders a list of issue_connections" do
        render

        duplicatee = @source_connection.target
        url = issue_path(duplicatee)
        expect(rendered).to have_link(nil, href: url)
      end

      it "doesn't render new connection link" do
        render

        url = new_issue_connection_path(@issue)
        expect(rendered).not_to have_link(nil, href: url)
      end

      it "renders destroy connection link" do
        render

        url = issue_connection_path(@source_connection)
        assert_select "a[data-method=\"delete\"][href=\"#{url}\"]"
      end
    end

    context "when a target_issue_connection" do
      before do
        @issue = assign(:issue, issue)
        @target_connection = Fabricate(:issue_connection, target: @issue)
        assign(:duplicates, [@target_connection.source])
      end

      it "renders a list of target_connections" do
        render

        duplicate = @target_connection.source
        url = issue_path(duplicate)
        expect(rendered).to have_link(nil, href: url)
      end
    end

    context "when comments" do
      before do
        @issue = assign(:issue, issue)
        @first_comment = Fabricate(:issue_comment, issue: @issue)
        @second_comment = Fabricate(:issue_comment, issue: @issue,
                                                    user: current_user)
        assign(:comments, [@first_comment, @second_comment])
      end

      it "renders a list of comments" do
        render

        assert_select "#comment-#{@first_comment.id}"
        assert_select "#comment-#{@second_comment.id}"

        first_url = issue_issue_comment_path(@issue, @first_comment)
        first_edit_url = edit_issue_issue_comment_path(@issue, @first_comment)
        second_url = issue_issue_comment_path(@issue, @second_comment)
        second_edit_url = edit_issue_issue_comment_path(@issue, @second_comment)
        expect(rendered).not_to have_link(nil, href: first_edit_url)
        expect(rendered).to have_link(nil, href: second_edit_url)

        assert_select "a[data-method='delete'][href='#{first_url}']", count: 0
        assert_select "a[data-method='delete'][href='#{second_url}']", count: 0
      end
    end

    context "when issue open" do
      before { @issue = assign(:issue, issue) }

      it "renders close issue link" do
        render

        url = issue_closures_path(@issue)
        assert_select "a[href='#{url}'][data-method='post']"
      end

      it "doesn't render open issue link" do
        render

        url = issue_reopenings_path(@issue)
        expect(rendered).not_to have_link(nil, href: url)
      end
    end

    context "when issue is resolved" do
      before do
        @issue = assign(:issue, closed_issue)
        @resolution = Fabricate(:resolution, issue: @issue, user: @issue.user)
      end

      it "renders resolution" do
        render

        assert_select "#resolution-history-#{@resolution.id}"
      end

      it "doesn't render destroy resolution link" do
        render

        url = issue_resolution_path(@issue, @resolution)
        expect(rendered).not_to have_link(nil, href: url)
      end
    end

    context "when issue is addressed" do
      let(:issue) { Fabricate(:closed_issue, project: @project) }

      before do
        @issue = assign(:issue, issue)
        Fabricate(:approved_task, issue: issue)
      end

      it "doesn't render disapprove resolution link" do
        render

        url = disapprove_issue_resolutions_path(@issue)
        expect(rendered).not_to have_link(nil, href: url)
      end

      it "doesn't render approve resolution link" do
        render

        url = approve_issue_resolutions_path(@issue)
        expect(rendered).not_to have_link(nil, href: url)
      end

      it "renders reopen issue link" do
        render

        url = issue_reopenings_path(@issue)
        assert_select "a[href='#{url}'][data-method='post']"
      end

      it "doesn't render close issue link" do
        render

        url = issue_closures_path(@issue)
        expect(rendered).not_to have_link(nil, href: url)
      end
    end

    context "when issue closed with a duplicate" do
      before do
        @issue = assign(:issue, closed_issue)
        issue_connection = Fabricate(:issue_connection, source: @issue)
        @source_connection = assign(:source_connection, issue_connection)
      end

      it "renders link to issue_connection target" do
        render

        url = issue_path(@source_connection.target)
        expect(rendered).to have_link(nil, href: url)
      end

      it "doesn't render close issue link" do
        render

        url = issue_closures_path(@issue)
        expect(rendered).not_to have_link(nil, href: url)
      end

      it "doesn't render open issue link" do
        render

        url = issue_reopenings_path(@issue)
        expect(rendered).not_to have_link(nil, href: url)
      end
    end

    context "when issue closed without a duplicate" do
      before { @issue = assign(:issue, closed_issue) }

      it "doesn't render close issue link" do
        render

        url = issue_closures_path(@issue)
        expect(rendered).not_to have_link(nil, href: url)
      end

      it "renders reopen issue link" do
        render

        url = issue_reopenings_path(@issue)
        assert_select "a[href='#{url}'][data-method='post']"
      end
    end

    context "when closures" do
      before do
        @issue = assign(:issue, issue)
        assign(:subscription, issue_subscription)
        assign(:issue_comment, @issue.comments.build(user_id: current_user.id))
        assign(:comments, [])
        @closure = Fabricate(:issue_closure, issue: issue)
      end

      it "renders list of closures" do
        render
        assert_select "#issue-closure-#{@closure.id}"
      end
    end

    context "when reopenings" do
      before do
        @issue = assign(:issue, issue)
        @reopening = Fabricate(:issue_reopening, issue: issue)
      end

      it "renders list of reopenings" do
        render
        assert_select "#issue-reopening-#{@reopening.id}"
      end
    end

    context "when issue project is internal" do
      let(:project) { Fabricate(:internal_project, category: category) }
      let(:issue) { Fabricate(:issue, project: project) }
      let(:closed_issue) { Fabricate(:closed_issue, project: project) }

      context "and open" do
        before { @issue = assign(:issue, issue) }

        it "renders new issue_comment form" do
          render

          url = issue_issue_comments_url(issue)
          assert_select "form[action=?][method=?]", url, "post"
        end

        it "renders new connection link" do
          render

          url = new_issue_connection_path(@issue)
          expect(rendered).to have_link(nil, href: url)
        end

        it "renders new task link" do
          render

          url =
            new_project_task_path(@issue.project, task: { issue_id: @issue.id })
          expect(rendered).to have_link(nil, href: url)
        end

        it "renders close issue link" do
          render

          url = issue_closures_path(@issue)
          assert_select "a[href='#{url}'][data-method='post']"
        end
      end

      context "and closed with a source_connection" do
        let(:issue_connection) { Fabricate(:issue_connection, source: @issue) }

        before do
          @issue = assign(:issue, closed_issue)
          @source_connection = assign(:source_connection, issue_connection)
        end

        it "renders source_connection" do
          render

          duplicatee = @source_connection.target
          url = issue_path(duplicatee)
          expect(rendered).to have_link(nil, href: url)
        end

        it "renders destroy connection link" do
          render

          url = issue_connection_path(@source_connection)
          assert_select "a[data-method=\"delete\"][href=\"#{url}\"]"
        end
      end

      context "and is closed with resolution" do
        before do
          @issue = assign(:issue, closed_issue)
          @resolution = Fabricate(:resolution, issue: @issue, user: @issue.user)
        end

        it "renders resolution" do
          render

          assert_select "#resolution-history-#{@resolution.id}"
        end

        it "renders reopen issue link" do
          render

          url = issue_reopenings_path(@issue)
          assert_select "a[href='#{url}'][data-method='post']"
        end
      end
    end

    context "when issue project is invisible" do
      let(:project) { Fabricate(:invisible_project, category: category) }
      let(:issue) { Fabricate(:issue, project: project) }
      let(:closed_issue) { Fabricate(:closed_issue, project: project) }

      context "and open" do
        before { @issue = assign(:issue, issue) }

        it "doesn't render new issue_comment form" do
          render

          url = issue_issue_comments_url(issue)
          assert_select "form[action=?]", url, count: 0
        end

        it "doesn't render new connection link" do
          render

          url = new_issue_connection_path(@issue)
          expect(rendered).not_to have_link(nil, href: url)
        end

        it "doesn't render new task link" do
          render

          url =
            new_project_task_path(@issue.project, task: { issue_id: @issue.id })
          expect(rendered).not_to have_link(nil, href: url)
        end

        it "doesn't render close issue link" do
          render

          url = issue_closures_path(@issue)
          expect(rendered).not_to have_link(nil, href: url)
        end
      end

      context "and closed with a source_connection" do
        let(:issue_connection) { Fabricate(:issue_connection, source: @issue) }

        before do
          @issue = assign(:issue, closed_issue)
          @source_connection = assign(:source_connection, issue_connection)
        end

        it "renders source_connection" do
          render

          duplicatee = @source_connection.target
          url = issue_path(duplicatee)
          expect(rendered).to have_link(nil, href: url)
        end

        it "doesn't render destroy connection link" do
          render

          url = issue_connection_path(@source_connection)
          expect(rendered).not_to have_link(nil, href: url)
        end
      end

      context "and is closed with resolution" do
        before do
          @issue = assign(:issue, closed_issue)
          @resolution = Fabricate(:resolution, issue: @issue, user: @issue.user)
        end

        it "renders resolution" do
          render

          assert_select "#resolution-history-#{@resolution.id}"
        end

        it "doesn't render reopen issue link" do
          render

          url = issue_reopenings_path(@issue)
          expect(rendered).not_to have_link(nil, href: url)
        end
      end
    end

    context "when issue has a github connection" do
      let(:project) { Fabricate(:project, category: category) }
      let(:issue) do
        Fabricate(:issue, project: project,
                          github_url: "https://github.com/user/repo")
      end

      before { @issue = assign(:issue, issue) }

      it "renders github issue link" do
        render

        expect(rendered).to have_link(nil, href: "https://github.com/user/repo")
      end
    end
  end

  %w[worker reporter].each do |employee_type|
    context "for a #{employee_type}" do
      let(:current_user) { Fabricate("user_#{employee_type}") }
      let(:issue_subscription) do
        Fabricate(:issue_subscription, issue: issue, user: current_user)
      end

      before do
        enable_can(view, current_user)
        assign(:duplicates, [])
        assign(:comments, [])
        assign(:subscription, issue_subscription)
        assign(:user, issue.user)
      end

      context "when their issue" do
        let(:url) { issue_issue_comments_url(@issue) }

        let(:issue) { Fabricate(:issue, project: @project, user: current_user) }

        before do
          @issue = assign(:issue, issue)
          @user = assign(:user, @issue.user)
        end

        it "renders issue's heading" do
          render template: subject, layout: "layouts/application"
          assert_select ".issue-heading", @issue.heading
        end

        it "renders new issue_comment form" do
          render

          assert_select "form[action=?][method=?]", url, "post" do
            assert_select "textarea[name=?]", "issue_comment[body]"
          end
        end

        it "renders edit link" do
          render

          url = edit_issue_path(@issue)
          expect(rendered).to have_link(nil, href: url)
        end

        it "renders approve resolution link" do
          render

          url = approve_issue_resolutions_path(@issue)
          expect(rendered).to have_link(nil, href: url)
        end

        it "doesn't render disapprove resolution link" do
          render

          url = disapprove_issue_resolutions_path(@issue)
          expect(rendered).not_to have_link(nil, href: url)
        end

        it "doesn't render the new task link" do
          render

          url =
            new_project_task_path(@issue.project, task: { issue_id: @issue.id })
          expect(rendered).not_to have_link(nil, href: url)
        end

        it "doesn't render close issue link" do
          render

          url = issue_closures_path(@issue)
          expect(rendered).not_to have_link(nil, href: url)
        end

        it "renders link to their issues" do
          render
          expect(rendered)
            .to have_link(nil, href: user_issues_path(current_user))
        end

        it "doesn't render move issue link" do
          render
          expect(rendered)
            .not_to have_link(nil, href: new_issue_move_path(@issue))
        end

        context "is addressed" do
          let(:issue) do
            Fabricate(:closed_issue, project: @project, user: current_user)
          end

          before do
            @issue = assign(:issue, issue)
            Fabricate(:approved_task, issue: issue)
          end

          it "renders disapprove resolution link" do
            render

            url = disapprove_issue_resolutions_path(@issue)
            expect(rendered).to have_link(nil, href: url)
          end

          it "doesn't render approve resolution link" do
            render

            url = approve_issue_resolutions_path(@issue)
            expect(rendered).not_to have_link(nil, href: url)
          end

          it "doesn't render open issue link" do
            render

            url = issue_reopenings_path(@issue)
            expect(rendered).not_to have_link(nil, href: url)
          end
        end

        context "is resolved" do
          let(:issue) do
            Fabricate(:closed_issue, project: @project, user: current_user)
          end

          before do
            @issue = assign(:issue, issue)
            @resolution =
              Fabricate(:resolution, issue: issue, user: current_user)
          end

          it "renders resolution" do
            render

            assert_select "#resolution-history-#{@resolution.id}"
          end

          it "doesn't render disapprove resolution link" do
            render

            url = disapprove_issue_resolutions_path(@issue)
            expect(rendered).not_to have_link(nil, href: url)
          end

          it "doesn't render approve resolution link" do
            render

            url = approve_issue_resolutions_path(@issue)
            expect(rendered).not_to have_link(nil, href: url)
          end

          it "doesn't render destroy resolution link" do
            render

            url = issue_resolution_path(@issue, @resolution)
            expect(rendered).not_to have_link(nil, href: url)
          end

          it "doesn't render open issue link" do
            render

            url = issue_reopenings_path(@issue)
            expect(rendered).not_to have_link(nil, href: url)
          end
        end
      end

      context "when someone else's issue" do
        let(:url) { issue_issue_comments_url(@issue) }

        before do
          @issue = assign(:issue, issue)
          @user = assign(:user, @issue.user)
        end

        it "renders issue's heading" do
          render template: subject, layout: "layouts/application"
          assert_select ".issue-heading", @issue.heading
        end

        it "renders new issue_comment form" do
          render

          assert_select "form[action=?][method=?]", url, "post" do
            assert_select "textarea[name=?]", "issue_comment[body]"
          end
        end

        it "doesn't render the edit link" do
          render

          url = edit_issue_path(@issue)
          expect(rendered).not_to have_link(nil, href: url)
        end

        it "doesn't render new connection link" do
          render

          url = new_issue_connection_path(@issue)
          expect(rendered).not_to have_link(nil, href: url)
        end

        it "doesn't render approve resolution link" do
          render

          url = approve_issue_resolutions_path(@issue)
          expect(rendered).not_to have_link(nil, href: url)
        end

        it "doesn't render close issue link" do
          render

          url = issue_closures_path(@issue)
          expect(rendered).not_to have_link(nil, href: url)
        end

        it "renders link to issue user's issues" do
          render
          expect(rendered).to have_link(nil, href: user_issues_path(@user))
        end

        context "is addressed" do
          let(:issue) { Fabricate(:closed_issue, project: @project) }

          before do
            @issue = assign(:issue, issue)
            Fabricate(:approved_task, issue: issue)
          end

          it "doesn't render disapprove resolution link" do
            render

            url = disapprove_issue_resolutions_path(@issue)
            expect(rendered).not_to have_link(nil, href: url)
          end

          it "doesn't render open issue link" do
            render

            url = issue_reopenings_path(@issue)
            expect(rendered).not_to have_link(nil, href: url)
          end
        end

        context "is resolved" do
          let(:issue) { Fabricate(:closed_issue, project: @project) }

          before do
            @issue = assign(:issue, issue)
            @resolution =
              Fabricate(:resolution, issue: issue, user: @issue.user)
          end

          it "renders resolution" do
            render

            assert_select "#resolution-history-#{@resolution.id}"
          end

          it "doesn't render disapprove resolution link" do
            render

            url = disapprove_issue_resolutions_path(@issue)
            expect(rendered).not_to have_link(nil, href: url)
          end

          it "doesn't render approve resolution link" do
            render

            url = approve_issue_resolutions_path(@issue)
            expect(rendered).not_to have_link(nil, href: url)
          end

          it "doesn't render destroy resolution link" do
            render

            url = issue_resolution_path(@issue, @resolution)
            expect(rendered).not_to have_link(nil, href: url)
          end
        end
      end

      context "when a source_connection" do
        before do
          @issue = assign(:issue, issue)
          issue_connection = Fabricate(:issue_connection, source: @issue)
          @source_connection = assign(:source_connection, issue_connection)
        end

        it "renders a list of issue_connections" do
          render

          duplicatee = @source_connection.target
          url = issue_path(duplicatee)
          expect(rendered).to have_link(nil, href: url)
        end

        it "doesn't render new connection link" do
          render

          url = new_issue_connection_path(@issue)
          expect(rendered).not_to have_link(nil, href: url)
        end

        it "doesn't render destroy connection link" do
          render

          url = issue_connection_path(@source_connection)
          assert_select "a[data-method=\"delete\"][href=\"#{url}\"]", count: 0
        end
      end

      context "when a target_issue_connection" do
        before do
          @issue = assign(:issue, issue)
          @target_connection = Fabricate(:issue_connection, target: @issue)
          assign(:duplicates, [@target_connection.source])
        end

        it "renders a list of target_connections" do
          render

          duplicate = @target_connection.source
          url = issue_path(duplicate)
          expect(rendered).to have_link(nil, href: url)
        end
      end

      context "when comments" do
        before do
          @issue = assign(:issue, issue)
          @first_comment = Fabricate(:issue_comment, issue: @issue)
          @second_comment = Fabricate(:issue_comment, issue: @issue,
                                                      user: current_user)
          assign(:comments, [@first_comment, @second_comment])
        end

        it "renders a list of comments" do
          render

          assert_select "#comment-#{@first_comment.id}"
          assert_select "#comment-#{@second_comment.id}"

          first_url = issue_issue_comment_path(@issue, @first_comment)
          first_edit_url = edit_issue_issue_comment_path(@issue, @first_comment)
          second_url = issue_issue_comment_path(@issue, @second_comment)
          second_edit_url =
            edit_issue_issue_comment_path(@issue, @second_comment)
          expect(rendered).not_to have_link(nil, href: first_edit_url)
          expect(rendered).to have_link(nil, href: second_edit_url)

          assert_select "a[data-method='delete'][href='#{first_url}']",
                        count: 0
          assert_select "a[data-method='delete'][href='#{second_url}']",
                        count: 0
        end
      end
    end
  end
end
