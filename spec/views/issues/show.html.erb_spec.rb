# frozen_string_literal: true

require "rails_helper"

RSpec.describe "issues/show", type: :view do
  before(:each) do
    @category = assign(:category, Fabricate(:category))
    @project = assign(:project, Fabricate(:project, category: @category))
  end

  context "for an admin" do
    let(:admin) { Fabricate(:user_admin) }

    before { enable_pundit(view, admin) }

    context "when project" do
      before do
        @issue = assign(:issue, Fabricate(:issue, project: @project))
        @comment = assign(:issue_comment, @issue.comments.build)
        @comments = assign(:comments, [])
      end

      let(:url) { issue_issue_comments_url(@issue) }

      it "renders issue's heading" do
        render
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

        url = new_issue_task_path(@issue)
        expect(rendered).to have_link(nil, href: url)
      end

      context "with tasks" do
        it "renders a list of tasks" do
          task = Fabricate(:task, issue: @issue)

          render
          assert_select "#task-#{task.id}"
        end
      end

      context "when a source_issue_connection" do
        before do
          @issue_connection = Fabricate(:issue_connection, source: @issue)
        end

        it "renders source_issue_connection" do
          render

          duplicatee = @issue_connection.target
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

          url = issue_connection_path(@issue_connection)
          assert_select "a[data-method=\"delete\"][href=\"#{url}\"]"
        end
      end

      context "when a target_issue_connection" do
        before do
          @issue_connection = Fabricate(:issue_connection, target: @issue)
        end

        it "renders a list of target_issue_connections" do
          render

          duplicate = @issue_connection.source
          url = issue_path(duplicate)
          expect(rendered).to have_link(nil, href: url)
        end
      end
    end

    context "when no project" do
      before do
        project = Fabricate(:project, category: @category)
        @issue = assign(:issue, Fabricate(:issue, project: project))
        @comment = assign(:issue_comment, @issue.comments.build)
        @comments = assign(:comments, [])
      end

      it "renders heading" do
        render
        assert_select ".issue-heading", @issue.heading
      end
    end

    context "when no issue_type" do
      before do
        @project = assign(:project, Fabricate(:project, category: @category))
        @issue = assign(:issue, Fabricate(:issue, project: @project))
        @comment = assign(:issue_comment, @issue.comments.build)
        @comments = assign(:comments, [])
        @issue.issue_type.destroy
        @issue.reload
      end

      it "renders heading" do
        render
        assert_select ".issue-heading", @issue.heading
      end
    end

    context "when issue's user destroyed" do
      before do
        @project = assign(:project, Fabricate(:project, category: @category))
        @issue = assign(:issue, Fabricate(:issue, project: @project))
        @comments = assign(:comments, [])
        @comment = assign(:issue_comment, @issue.comments.build)

        @issue.user.destroy
        @issue.reload
      end

      it "renders default user name" do
        render
        assert_select ".issue-user", User.destroyed_name
      end
    end

    context "when comment's user destroyed" do
      let(:user) { Fabricate(:user_worker) }

      before do
        @issue = assign(:issue, Fabricate(:issue))
        @issue_comment = Fabricate(:issue_comment, issue: @issue, user: user)
        @comments = assign(:comments, [@issue_comment])
        @comment = assign(:issue_comment, @issue.comments.build)

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
        @project = assign(:project, Fabricate(:project, category: @category))
        @issue = Fabricate(:issue, project: @project)
        @task =
          assign(:task, Fabricate(:task, project: @project, issue: @issue))
        @comment = assign(:issue_comment, @issue.comments.build)
        @comments = assign(:comments, [])

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
        @issue = assign(:issue, Fabricate(:issue, project: @project))
        @comment = assign(:issue_comment, @issue.comments.build)
        @first_comment = Fabricate(:issue_comment, issue: @issue)
        @second_comment = Fabricate(:issue_comment, issue: @issue, user: admin)
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
  end

  context "for a reviewer" do
    let(:reviewer) { Fabricate(:user_reviewer) }

    before { enable_pundit(view, reviewer) }

    before do
      @project = assign(:project, Fabricate(:project, category: @category))
    end

    context "when someone else's issue" do
      let(:url) { issue_issue_comments_url(@issue) }

      before do
        @issue = assign(:issue, Fabricate(:issue, project: @project))
        @comment = assign(:issue_comment, @issue.comments.build)
        @comments = assign(:comments, [])
      end

      it "renders issue's heading" do
        render
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

        url = new_issue_task_path(@issue)
        expect(rendered).to have_link(nil, href: url)
      end
    end

    context "when a source_issue_connection" do
      before do
        @issue = assign(:issue, Fabricate(:issue, project: @project))
        @comment = assign(:issue_comment, @issue.comments.build)
        @comments = assign(:comments, [])
        @issue_connection = Fabricate(:issue_connection, source: @issue)
      end

      it "renders a list of issue_connections" do
        render

        duplicatee = @issue_connection.target
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

        url = issue_connection_path(@issue_connection)
        assert_select "a[data-method=\"delete\"][href=\"#{url}\"]"
      end
    end

    context "when a target_issue_connection" do
      before do
        @issue = assign(:issue, Fabricate(:issue, project: @project))
        @comment = assign(:issue_comment, @issue.comments.build)
        @comments = assign(:comments, [])
        @issue_connection = Fabricate(:issue_connection, target: @issue)
      end

      it "renders a list of target_issue_connections" do
        render

        duplicate = @issue_connection.source
        url = issue_path(duplicate)
        expect(rendered).to have_link(nil, href: url)
      end
    end

    context "when comments" do
      before do
        @issue = assign(:issue, Fabricate(:issue, project: @project))
        @comment = assign(:issue_comment, @issue.comments.build)
        @first_comment = Fabricate(:issue_comment, issue: @issue)
        @second_comment = Fabricate(:issue_comment, issue: @issue,
                                                    user: reviewer)
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
        expect(rendered).not_to have_link(nil, href: first_edit_url)
        expect(rendered).to have_link(nil, href: second_edit_url)

        assert_select "a[data-method='delete'][href='#{first_url}']", count: 0
        assert_select "a[data-method='delete'][href='#{second_url}']", count: 0
      end
    end
  end

  %w[worker reporter].each do |employee_type|
    context "for a #{employee_type}" do
      let(:current_user) { Fabricate("user_#{employee_type}") }

      before { enable_pundit(view, current_user) }

      context "when their issue" do
        let(:url) { issue_issue_comments_url(@issue) }

        let(:issue) { Fabricate(:issue, project: @project, user: current_user) }

        before do
          @issue = assign(:issue, issue)
          @comment = assign(:issue_comment, @issue.comments.build)
          @comments = assign(:comments, [])
        end

        it "renders issue's heading" do
          render
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

          url = new_issue_task_path(@issue)
          expect(rendered).not_to have_link(nil, href: url)
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
        end
      end

      context "when someone else's issue" do
        let(:url) { issue_issue_comments_url(@issue) }

        before do
          @issue = assign(:issue, Fabricate(:issue, project: @project))
          @comment = assign(:issue_comment, @issue.comments.build)
          @comments = assign(:comments, [])
        end

        it "renders issue's heading" do
          render
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
        end
      end

      context "when a source_issue_connection" do
        before do
          @issue = assign(:issue, Fabricate(:issue, project: @project))
          @comment = assign(:issue_comment, @issue.comments.build)
          @comments = assign(:comments, [])
          @issue_connection = Fabricate(:issue_connection, source: @issue)
        end

        it "renders a list of issue_connections" do
          render

          duplicatee = @issue_connection.target
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

          url = issue_connection_path(@issue_connection)
          assert_select "a[data-method=\"delete\"][href=\"#{url}\"]", count: 0
        end
      end

      context "when a target_issue_connection" do
        before do
          @issue = assign(:issue, Fabricate(:issue, project: @project))
          @comment = assign(:issue_comment, @issue.comments.build)
          @comments = assign(:comments, [])
          @issue_connection = Fabricate(:issue_connection, target: @issue)
        end

        it "renders a list of target_issue_connections" do
          render

          duplicate = @issue_connection.source
          url = issue_path(duplicate)
          expect(rendered).to have_link(nil, href: url)
        end
      end

      context "when comments" do
        before do
          @issue = assign(:issue, Fabricate(:issue, project: @project))
          @comment = assign(:issue_comment, @issue.comments.build)
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
          first_edit_url =
            edit_issue_issue_comment_path(@issue, @first_comment)
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
