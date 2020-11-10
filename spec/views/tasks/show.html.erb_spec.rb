# frozen_string_literal: true

require "rails_helper"

RSpec.describe "tasks/show", type: :view do
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:task) { Fabricate(:task, project: project) }

  before(:each) { @category = assign(:category, category) }

  context "for an admin" do
    let(:admin) { Fabricate(:user_admin) }
    let(:task_subscription) do
      Fabricate(:task_subscription, task: task, user: admin)
    end

    before do
      enable_can(view, admin)
      @project = assign(:project, project)
    end

    context "when project" do
      before do
        @task = assign(:task, task)
        @task_subscription = assign(:task_subscription, task_subscription)
      end

      let(:url) { task_task_comments_url(@task) }

      it "renders task's heading" do
        render
        assert_select ".task-heading", @task.heading
      end

      it "renders task's description" do
        render
        assert_select ".task-description main", @task.description
      end

      it "renders task's user" do
        render
        assert_select ".task-user", @task.user.name_or_email
      end

      it "renders new task_comment form" do
        render

        assert_select "form[action=?][method=?]", url, "post" do
          assert_select "textarea[name=?]", "task_comment[body]"
        end
      end

      it "renders new task connection link" do
        render
        expect(rendered)
          .to have_link(nil, href: new_task_connection_path(@task))
      end

      context "task belongs to an issue" do
        let(:issue) { Fabricate(:issue, project: @project) }

        before do
          @task =
            assign(:task, Fabricate(:task, project: @project, issue: issue))
        end

        it "renders issue" do
          render
          assert_select "#issue-#{issue.id}"
        end
      end

      context "task assigned to a user" do
        let(:user) { Fabricate(:user_worker) }

        before do
          Fabricate(:task_assignee, task: @task, assignee: user)
        end

        it "renders assignee" do
          render
          assert_select "#assignee-#{user.id}"
        end
      end

      context "when task has comments" do
        let(:user) { Fabricate(:user_worker) }

        before do
          Fabricate(:task_assignee, task: @task, assignee: user)
          @task_comment = Fabricate(:task_comment, task: @task)
        end

        it "renders them" do
          render
          assert_select "#comment-#{@task_comment.id}"
        end
      end
    end

    context "when no task_type" do
      before do
        @task = assign(:task, task)
        assign(:task_subscription, task_subscription)

        @task.task_type.destroy
        @task.reload
      end

      it "renders heading" do
        render
        assert_select ".task-heading", @task.heading
      end
    end

    context "when task's user destroyed" do
      before do
        @task = assign(:task, task)
        assign(:task_subscription, task_subscription)

        @task.user.destroy
        @task.reload
      end

      it "renders default user name" do
        render
        assert_select ".task-user", User.destroyed_name
      end
    end

    context "when comment's user destroyed" do
      let(:user) { Fabricate(:user_worker) }

      before do
        @task = assign(:task, task)
        @task_comment = Fabricate(:task_comment, task: @task, user: user)
        assign(:task_subscription, task_subscription)

        @task_comment.user.destroy
        @task_comment.reload
      end

      it "renders default user name" do
        render
        assert_select "#comment-#{@task_comment.id} .comment-user",
                      User.destroyed_name
      end
    end

    context "when task's assignee destroyed" do
      let(:user) { Fabricate(:user_worker) }

      before do
        @task = assign(:task, task)
        Fabricate(:task_assignee, task: @task, assignee: user)
        assign(:task_subscription, task_subscription)

        user.destroy
        @task.reload
      end

      it "renders" do
        expect do
          render
        end.not_to raise_error
      end
    end

    context "task's issue destroyed" do
      before do
        @issue = Fabricate(:issue, project: @project)
        @task =
          assign(:task, Fabricate(:task, project: @project, issue: @issue))
        assign(:task_subscription, task_subscription)

        @issue.destroy
        @task.reload
      end

      it "renders" do
        expect do
          render
        end.not_to raise_error
      end
    end

    context "when task is in review" do
      before do
        @task = assign(:task, task)
        assign(:task_subscription, task_subscription)
        @review = Fabricate(:pending_review, task: @task)
      end

      it "renders approval link" do
        render
        expect(rendered)
          .to have_link(nil, href: approve_task_review_path(@task, @review))
      end

      it "renders disapproval link" do
        render
        expect(rendered)
          .to have_link(nil, href: disapprove_task_review_path(@task, @review))
      end

      it "renders edit link" do
        render
        url = edit_task_path(@task)
        expect(rendered).to have_link(nil, href: url)
      end
    end

    context "when task doesn't have a source_connection" do
      before do
        @task = assign(:task, task)
        assign(:task_subscription, task_subscription)
      end

      it "renders new task connection link" do
        render
        expect(rendered)
          .to have_link(nil, href: new_task_connection_path(@task))
      end
    end

    context "when task has a source_connection" do
      before do
        @task = assign(:task, task)
        assign(:task_subscription, task_subscription)
        @task_connection = Fabricate(:task_connection, source: @task)
      end

      it "renders link to target task" do
        render
        target = @task_connection.target
        url = task_path(target)
        expect(rendered).to have_link(nil, href: url)
      end

      it "renders destroy link" do
        render
        url = task_connection_path(@task_connection)
        assert_select "a[data-method=\"delete\"][href=\"#{url}\"]"
      end

      it "doesn't render a new task connection link" do
        render
        expect(rendered)
          .not_to have_link(nil, href: new_task_connection_path(@task))
      end
    end

    context "when task has target_connections" do
      before do
        @task = assign(:task, task)
        assign(:task_subscription, task_subscription)
        @task_connection = Fabricate(:task_connection, target: @task)
      end

      it "renders link to source task" do
        render
        source = @task_connection.source
        url = task_path(source)
        expect(rendered).to have_link(nil, href: url)
      end
    end

    context "when an unfinished progression" do
      before do
        @task = assign(:task, task)
        assign(:task_subscription, task_subscription)
        @task.assignees << @task.user
        @progression = Fabricate(:unfinished_progression, task: @task)
      end

      it "doesn't render the progression" do
        render
        assert_select "#progression_#{@progression.id}", count: 0
      end

      it "doesn't render the finish link" do
        render
        url = finish_task_progression_path(@task, @progression)
        expect(rendered).not_to have_link(nil, href: url)
      end

      it "doesn't render the new progression link" do
        render
        url = task_progressions_path(
          @task,
          progression: { user_id: @task.user_id }
        )
        expect(rendered).not_to have_link(nil, href: url)
      end
    end

    context "when a finished progression" do
      before do
        @task = assign(:task, task)
        assign(:task_subscription, task_subscription)
        @task.assignees << @task.user
        @progression = Fabricate(:finished_progression, task: @task)
      end

      it "doesn't render the progression" do
        render
        assert_select "#progression_#{@progression.id}", count: 0
      end

      it "doesn't render the new progression link" do
        render
        url = task_progressions_path(
          @task,
          progression: { user_id: @task.user_id }
        )
        expect(rendered).not_to have_link(nil, href: url)
      end

      it "doesn't render the finish link" do
        render
        url = finish_task_progression_path(@task, @progression)
        expect(rendered).not_to have_link(nil, href: url)
      end

      it "doesn't render destroy progression link" do
        render
        url = task_progression_path(@task, @progression)
        assert_select "a[data-method=\"delete\"][href=\"#{url}\"]", count: 0
      end
    end

    context "when no review" do
      before do
        @task = assign(:task, task)
        assign(:task_subscription, task_subscription)
        @task.assignees << @task.user
      end

      it "doesn't render new review link" do
        render
        expect(rendered).not_to have_link(nil, href: task_reviews_path(@task))
      end
    end

    context "when a pending review" do
      before do
        @task = assign(:task, task)
        assign(:task_subscription, task_subscription)
        @task.assignees << @task.user
        @review = Fabricate(:pending_review, task: @task)
      end

      it "doesn't render destroy review link" do
        render
        url = task_review_path(@task, @review)
        assert_select "a[data-method=\"delete\"][href=\"#{url}\"]", count: 0
      end

      it "doesn't render new review link" do
        render
        expect(rendered).not_to have_link(nil, href: task_reviews_path(@task))
      end

      it "renders approve review link" do
        render
        url = approve_task_review_path(@task, @review)
        expect(rendered).to have_link(nil, href: url)
      end

      it "renders disapprove review link" do
        render
        url = disapprove_task_review_path(@task, @review)
        expect(rendered).to have_link(nil, href: url)
      end
    end

    context "when comments" do
      before do
        @task = assign(:task, task)
        assign(:task_subscription, task_subscription)
        @comment = assign(:task_comment, @task.comments.build)
        @first_comment = Fabricate(:task_comment, task: @task)
        @second_comment = Fabricate(:task_comment, task: @task, user: admin)
        @comments = assign(:comments, [@first_comment, @second_comment])
      end

      it "renders a list of comments" do
        render

        assert_select "#comment-#{@first_comment.id}"
        assert_select "#comment-#{@second_comment.id}"

        first_url = task_task_comment_path(@task, @first_comment)
        first_edit_url = edit_task_task_comment_path(@task, @first_comment)
        second_url = task_task_comment_path(@task, @second_comment)
        second_edit_url = edit_task_task_comment_path(@task, @second_comment)
        expect(rendered).to have_link(nil, href: first_edit_url)
        expect(rendered).to have_link(nil, href: second_edit_url)

        assert_select "a[data-method='delete'][href='#{first_url}']"
        assert_select "a[data-method='delete'][href='#{second_url}']"
      end
    end
  end

  context "for an reviewer" do
    let(:reviewer) { Fabricate(:user_reviewer) }
    let(:task_subscription) do
      Fabricate(:task_subscription, task: task, user: reviewer)
    end

    before do
      enable_can(view, reviewer)
      @project = assign(:project, project)
    end

    context "when task is open" do
      before do
        @task = assign(:task, task)
        assign(:task_subscription, task_subscription)
      end

      it "renders task's heading" do
        render
        assert_select ".task-heading", @task.heading
      end

      it "renders new task_comment form" do
        render

        url = task_task_comments_url(@task)
        assert_select "form[action=?][method=?]", url, "post" do
          assert_select "textarea[name=?]", "task_comment[body]"
        end
      end

      it "doesn't render edit link" do
        render
        url = edit_task_path(@task)
        expect(rendered).not_to have_link(nil, href: url)
      end

      it "renders new task connection link" do
        render
        url = new_task_connection_path(@task)
        expect(rendered).to have_link(nil, href: url)
      end

      it "doesn't render close link" do
        render
        expect(rendered).not_to have_link(nil, href: close_task_path(@task))
      end
    end

    context "when task is closed" do
      before do
        @task = assign(:task, Fabricate(:closed_task, project: @project))
        assign(:task_subscription,
               Fabricate(:task_subscription, task: @task, user: reviewer))
      end

      it "doesn't render reopen link" do
        render
        expect(rendered).not_to have_link(nil, href: open_task_path(@task))
      end
    end

    context "when task has a source_connection" do
      before do
        @task = assign(:task, task)
        assign(:task_subscription, task_subscription)
        @task_connection = Fabricate(:task_connection, source: @task)
      end

      it "renders link to target task" do
        render
        target = @task_connection.target
        url = task_path(target)
        expect(rendered).to have_link(nil, href: url)
      end

      it "renders destroy link" do
        render
        url = task_connection_path(@task_connection)
        assert_select "a[data-method=\"delete\"][href=\"#{url}\"]"
      end
    end

    context "when task has target_connections" do
      before do
        @task = assign(:task, task)
        assign(:task_subscription, task_subscription)
        @task_connection = Fabricate(:task_connection, target: @task)
      end

      it "renders link to source task" do
        render
        source = @task_connection.source
        url = task_path(source)
        expect(rendered).to have_link(nil, href: url)
      end
    end

    context "when an unfinished progression" do
      before do
        @task = assign(:task, task)
        assign(:task_subscription, task_subscription)
        @task.assignees << @task.user
        @progression = Fabricate(:unfinished_progression, task: @task)
      end

      it "doesn't render the progression" do
        render
        assert_select "#progression_#{@progression.id}", count: 0
      end

      it "doesn't render the finish link" do
        render
        url = finish_task_progression_path(@task, @progression)
        expect(rendered).not_to have_link(nil, href: url)
      end

      it "doesn't render destroy progression link" do
        render
        url = task_progression_path(@task, @progression)
        assert_select "a[data-method=\"delete\"][href=\"#{url}\"]", count: 0
      end

      it "doesn't render the new progression link" do
        render
        url = task_progressions_path(
          @task,
          progression: { user_id: @task.user_id }
        )
        expect(rendered).not_to have_link(nil, href: url)
      end
    end

    context "when a finished progression" do
      before do
        @task = assign(:task, task)
        assign(:task_subscription, task_subscription)
        @task.assignees << @task.user
        @progression = Fabricate(:finished_progression, task: @task)
      end

      it "doesn't render the progression" do
        render
        assert_select "#progression_#{@progression.id}", count: 0
      end

      it "doesn't render the new progression link" do
        render
        url = task_progressions_path(
          @task,
          progression: { user_id: @task.user_id }
        )
        expect(rendered).not_to have_link(nil, href: url)
      end

      it "doesn't render the finish link" do
        render
        url = finish_task_progression_path(@task, @progression)
        expect(rendered).not_to have_link(nil, href: url)
      end

      it "doesn't render destroy progression link" do
        render
        url = task_progression_path(@task, @progression)
        assert_select "a[data-method=\"delete\"][href=\"#{url}\"]", count: 0
      end
    end

    context "when no review" do
      before do
        @task = assign(:task, task)
        assign(:task_subscription, task_subscription)
        @task.assignees << @task.user
      end

      it "doesn't render new review link" do
        render
        expect(rendered).not_to have_link(nil, href: task_reviews_path(@task))
      end
    end

    context "when a pending review" do
      before do
        @task = assign(:task, task)
        assign(:task_subscription, task_subscription)
        @task.assignees << @task.user
        @review = Fabricate(:pending_review, task: @task)
      end

      it "doesn't render destroy review link" do
        render
        url = task_review_path(@task, @review)
        assert_select "a[data-method=\"delete\"][href=\"#{url}\"]", count: 0
      end

      it "doesn't render new review link" do
        render
        expect(rendered).not_to have_link(nil, href: task_reviews_path(@task))
      end

      it "renders approve review link" do
        render
        url = approve_task_review_path(@task, @review)
        expect(rendered).to have_link(nil, href: url)
      end

      it "renders disapprove review link" do
        render
        url = disapprove_task_review_path(@task, @review)
        expect(rendered).to have_link(nil, href: url)
      end
    end

    context "when comments" do
      before do
        @task = assign(:task, task)
        assign(:task_subscription, task_subscription)
        @comment = assign(:task_comment, @task.comments.build)
        @first_comment = Fabricate(:task_comment, task: @task)
        @second_comment = Fabricate(:task_comment, task: @task, user: reviewer)
        @comments = assign(:comments, [@first_comment, @second_comment])
      end

      it "renders a list of comments" do
        render

        assert_select "#comment-#{@first_comment.id}"
        assert_select "#comment-#{@second_comment.id}"

        first_url = task_task_comment_path(@task, @first_comment)
        first_edit_url = edit_task_task_comment_path(@task, @first_comment)
        second_url = task_task_comment_path(@task, @second_comment)
        second_edit_url = edit_task_task_comment_path(@task, @second_comment)
        expect(rendered).not_to have_link(nil, href: first_edit_url)
        expect(rendered).to have_link(nil, href: second_edit_url)

        assert_select "a[data-method='delete'][href='#{first_url}']", count: 0
        assert_select "a[data-method='delete'][href='#{second_url}']", count: 0
      end
    end

    context "when not subscribed to the task" do
      before do
        @task = assign(:task, task)
        assign(:task_subscription,
               Fabricate.build(:task_subscription, task: @task, user: reviewer))
        @comment = assign(:task_comment, @task.comments.build)
      end

      it "renders new task_subscription link" do
        render
        expect(rendered)
          .to have_link(nil, href: task_task_subscriptions_path(@task))
      end
    end

    context "when subscribed to the task" do
      before do
        @task = assign(:task, task)
        @comment = assign(:task_comment, @task.comments.build)
        @task_subscription = assign(:task_subscription, task_subscription)
      end

      it "doesn't render new task_subscription link" do
        render
        url = task_task_subscriptions_path(@task)
        expect(rendered).not_to have_link(nil, href: url)
      end

      it "renders destroy task_subscription link" do
        render
        url = task_task_subscription_path(@task, @task_subscription)
        assert_select "a[data-method='delete'][href='#{url}']"
      end
    end
  end

  context "for a worker" do
    let(:current_user) { Fabricate("user_worker") }
    let(:task_subscription) do
      Fabricate(:task_subscription, task: task, user: current_user)
    end

    before do
      enable_can(view, current_user)
      @project = assign(:project, project)
    end

    context "when task is open" do
      before do
        @task = assign(:task, task)
        assign(:task_subscription, task_subscription)
      end

      it "renders task's heading" do
        render
        assert_select ".task-heading", @task.heading
      end

      it "renders new task_comment form" do
        render

        url = task_task_comments_url(@task)
        assert_select "form[action=?][method=?]", url, "post" do
          assert_select "textarea[name=?]", "task_comment[body]"
        end
      end

      it "doesn't render new task connection link" do
        render
        url = new_task_connection_path(@task)
        expect(rendered).not_to have_link(nil, href: url)
      end

      it "doesn't render close link" do
        render
        expect(rendered).not_to have_link(nil, href: close_task_path(@task))
      end
    end

    context "when task is closed" do
      before do
        @task = assign(:task, Fabricate(:closed_task, project: @project))
        assign(:task_subscription,
               Fabricate(:task_subscription, task: @task, user: current_user))
      end

      it "doesn't render reopen link" do
        render
        expect(rendered).not_to have_link(nil, href: open_task_path(@task))
      end
    end

    context "when Task assigned to them" do
      before do
        @task = assign(:task, task)
        assign(:task_subscription, task_subscription)
        @task.assignees << current_user
      end

      context "and they have an unfinished progression" do
        before do
          @progression = Fabricate(:unfinished_progression, user: current_user,
                                                            task: @task)
        end

        it "renders the progression" do
          render
          assert_select "#progression_#{@progression.id}"
        end

        it "renders the finish link" do
          render
          url = finish_task_progression_path(@task, @progression)
          expect(rendered).to have_link(nil, href: url)
        end

        it "renders new review link" do
          render
          url = task_reviews_path(@task)
          expect(rendered).to have_link(nil, href: url)
        end

        it "doesn't render destroy progression link" do
          render
          url = task_progression_path(@task, @progression)
          assert_select "a[data-method=\"delete\"][href=\"#{url}\"]", count: 0
        end

        it "doesn't render the new progression link" do
          render
          url = task_progressions_path(@task)
          expect(rendered).not_to have_link(nil, href: url)
        end
      end

      context "and they have an finished progression" do
        before do
          @progression = Fabricate(:finished_progression, user: current_user,
                                                          task: @task)
        end

        it "doesn't render the progression" do
          render
          assert_select "#progression_#{@progression.id}", count: 0
        end

        it "renders the new progression link" do
          render
          url = task_progressions_path(@task)
          expect(rendered).to have_link(nil, href: url)
        end

        it "doesn't render the finish link" do
          render
          url = finish_task_progression_path(@task, @progression)
          expect(rendered).not_to have_link(nil, href: url)
        end

        it "doesn't render destroy progression link" do
          render
          url = task_progression_path(@task, @progression)
          assert_select "a[data-method=\"delete\"][href=\"#{url}\"]", count: 0
        end
      end

      context "with no review" do
        it "renders new review link" do
          render
          expect(rendered).to have_link(nil, href: task_reviews_path(@task))
        end
      end

      context "with a pending review" do
        before do
          @review = Fabricate(:pending_review, task: @task)
        end

        it "doesn't render destroy review link" do
          render
          url = task_review_path(@task, @review)
          assert_select "a[data-method=\"delete\"][href=\"#{url}\"]", count: 0
        end

        it "doesn't render new review link" do
          render
          expect(rendered).not_to have_link(nil, href: task_reviews_path(@task))
        end

        it "doesn't render approve review link" do
          render
          url = approve_task_review_path(@task, @review)
          expect(rendered).not_to have_link(nil, href: url)
        end

        it "doesn't render disapprove review link" do
          render
          url = disapprove_task_review_path(@task, @review)
          expect(rendered).not_to have_link(nil, href: url)
        end
      end
    end

    context "when someone else's Task" do
      before do
        @task = assign(:task, task)
        assign(:task_subscription, task_subscription)
        @task.assignees << @task.user
      end

      it "renders new task_comment form" do
        render

        url = task_task_comments_url(@task)
        assert_select "form[action=?][method=?]", url, "post" do
          assert_select "textarea[name=?]", "task_comment[body]"
        end
      end

      it "doesn't render edit link" do
        render
        url = edit_task_path(@task)
        expect(rendered).not_to have_link(nil, href: url)
      end

      it "doesn't render new review link" do
        render
        url = task_reviews_path(@task)
        expect(rendered).not_to have_link(nil, href: url)
      end

      context "with no review" do
        it "doesn't render new review link" do
          render
          expect(rendered).not_to have_link(nil, href: task_reviews_path(@task))
        end
      end

      context "with a pending review" do
        before do
          @review = Fabricate(:pending_review, task: @task)
        end

        it "doesn't render destroy review link" do
          render
          url = task_review_path(@task, @review)
          assert_select "a[data-method=\"delete\"][href=\"#{url}\"]", count: 0
        end

        it "doesn't render new review link" do
          render
          expect(rendered).not_to have_link(nil, href: task_reviews_path(@task))
        end

        it "doesn't render approve review link" do
          render
          url = approve_task_review_path(@task, @review)
          expect(rendered).not_to have_link(nil, href: url)
        end

        it "doesn't render disapprove review link" do
          render
          url = disapprove_task_review_path(@task, @review)
          expect(rendered).not_to have_link(nil, href: url)
        end
      end
    end

    context "when task has a source_connection" do
      before do
        @task = assign(:task, task)
        assign(:task_subscription, task_subscription)
        @task_connection = Fabricate(:task_connection, source: @task)
      end

      it "renders link to target task" do
        render
        target = @task_connection.target
        url = task_path(target)
        expect(rendered).to have_link(nil, href: url)
      end

      it "doesn't render destroy link" do
        render
        url = task_connection_path(@task_connection)
        assert_select "a[data-method=\"delete\"][href=\"#{url}\"]", count: 0
      end
    end

    context "when task has target_connections" do
      before do
        @task = assign(:task, task)
        assign(:task_subscription, task_subscription)
        @task_connection = Fabricate(:task_connection, target: @task)
      end

      it "renders link to source task" do
        render
        source = @task_connection.source
        url = task_path(source)
        expect(rendered).to have_link(nil, href: url)
      end
    end

    context "when a pending review" do
      before do
        @task = assign(:task, task)
        assign(:task_subscription, task_subscription)
        @task.assignees << @task.user
        @review = Fabricate(:pending_review, task: @task)
      end

      it "doesn't render destroy review link" do
        render
        url = task_review_path(@task, @review)
        assert_select "a[data-method=\"delete\"][href=\"#{url}\"]", count: 0
      end

      it "doesn't render new review link" do
        render
        expect(rendered).not_to have_link(nil, href: task_reviews_path(@task))
      end

      it "doesn't render approve review link" do
        render
        url = approve_task_review_path(@task, @review)
        expect(rendered).not_to have_link(nil, href: url)
      end

      it "doesn't render disapprove review link" do
        render
        url = disapprove_task_review_path(@task, @review)
        expect(rendered).not_to have_link(nil, href: url)
      end
    end

    context "when comments" do
      before do
        @task = assign(:task, task)
        assign(:task_subscription, task_subscription)
        @comment = assign(:task_comment, @task.comments.build)
        @first_comment = Fabricate(:task_comment, task: @task)
        @second_comment =
          Fabricate(:task_comment, task: @task, user: current_user)
        @comments = assign(:comments, [@first_comment, @second_comment])
      end

      it "renders a list of comments" do
        render

        assert_select "#comment-#{@first_comment.id}"
        assert_select "#comment-#{@second_comment.id}"

        first_url = task_task_comment_path(@task, @first_comment)
        first_edit_url = edit_task_task_comment_path(@task, @first_comment)
        second_url = task_task_comment_path(@task, @second_comment)
        second_edit_url = edit_task_task_comment_path(@task, @second_comment)
        expect(rendered).not_to have_link(nil, href: first_edit_url)
        expect(rendered).to have_link(nil, href: second_edit_url)

        assert_select "a[data-method='delete'][href='#{first_url}']", count: 0
        assert_select "a[data-method='delete'][href='#{second_url}']", count: 0
      end
    end
  end

  context "for a reporter" do
    let(:current_user) { Fabricate("user_reporter") }
    let(:task_subscription) do
      Fabricate(:task_subscription, task: task, user: current_user)
    end

    before do
      enable_can(view, current_user)
      @project = assign(:project, project)
    end

    context "when task is open" do
      before do
        @task = assign(:task, task)
        assign(:task_subscription, task_subscription)
        @review = Fabricate(:pending_review, task: @task)
      end

      it "renders task's heading" do
        render
        assert_select ".task-heading", @task.heading
      end

      it "renders new task_comment form" do
        render

        url = task_task_comments_url(@task)
        assert_select "form[action=?][method=?]", url, "post" do
          assert_select "textarea[name=?]", "task_comment[body]"
        end
      end

      it "renders new task_comment form" do
        render

        url = task_task_comments_url(@task)
        assert_select "form[action=?][method=?]", url, "post" do
          assert_select "textarea[name=?]", "task_comment[body]"
        end
      end

      it "doesn't render new task connection link" do
        render
        url = new_task_connection_path(@task)
        expect(rendered).not_to have_link(nil, href: url)
      end

      it "doesn't render close link" do
        render
        expect(rendered).not_to have_link(nil, href: close_task_path(@task))
      end

      it "doesn't render edit link" do
        render
        url = edit_task_path(@task)
        expect(rendered).not_to have_link(nil, href: url)
      end
    end

    context "when task is closed" do
      before do
        @task = assign(:task, Fabricate(:closed_task, project: @project))
        assign(:task_subscription,
               Fabricate(:task_subscription, task: task, user: current_user))
      end

      it "doesn't render reopen link" do
        render
        expect(rendered).not_to have_link(nil, href: open_task_path(@task))
      end
    end

    context "when task has a source_connection" do
      before do
        @task = assign(:task, task)
        assign(:task_subscription, task_subscription)
        @task_connection = Fabricate(:task_connection, source: @task)
      end

      it "renders link to target task" do
        render
        target = @task_connection.target
        url = task_path(target)
        expect(rendered).to have_link(nil, href: url)
      end

      it "doesn't render destroy link" do
        render
        url = task_connection_path(@task_connection)
        assert_select "a[data-method=\"delete\"][href=\"#{url}\"]", count: 0
      end
    end

    context "when task has target_connections" do
      before do
        @task = assign(:task, task)
        assign(:task_subscription, task_subscription)
        @task_connection = Fabricate(:task_connection, target: @task)
      end

      it "renders link to source task" do
        render
        source = @task_connection.source
        url = task_path(source)
        expect(rendered).to have_link(nil, href: url)
      end
    end

    context "when task has an unfinished progression" do
      before do
        @task = assign(:task, task)
        assign(:task_subscription, task_subscription)
        @task.assignees << @task.user
        @progression = Fabricate(:unfinished_progression, task: @task)
      end

      it "doesn't render the progression" do
        render
        assert_select "#progression_#{@progression.id}", count: 0
      end

      it "doesn't render the finish link" do
        render
        url = finish_task_progression_path(@task, @progression)
        expect(rendered).not_to have_link(nil, href: url)
      end

      it "doesn't render new review link" do
        render
        url = task_reviews_path(@task, review: { user_id: @task.user_id })
        expect(rendered).not_to have_link(nil, href: url)
      end

      it "doesn't render destroy progression link" do
        render
        url = task_progression_path(@task, @progression)
        assert_select "a[data-method=\"delete\"][href=\"#{url}\"]", count: 0
      end

      it "doesn't render the new progression link" do
        render
        url = task_progressions_path(@task)
        expect(rendered).not_to have_link(nil, href: url)
      end
    end

    context "when task has a finished progression" do
      before do
        @task = assign(:task, task)
        assign(:task_subscription, task_subscription)
        @task.assignees << @task.user
        @progression = Fabricate(:finished_progression, task: @task)
      end

      it "doesn't render the progression" do
        render
        assert_select "#progression_#{@progression.id}", count: 0
      end

      it "doesn't render the new progression link" do
        render
        url = task_progressions_path(@task)
        expect(rendered).not_to have_link(nil, href: url)
      end

      it "doesn't render the finish link" do
        render
        url = finish_task_progression_path(@task, @progression)
        expect(rendered).not_to have_link(nil, href: url)
      end

      it "doesn't render new review link" do
        render
        url = task_reviews_path(@task)
        expect(rendered).not_to have_link(nil, href: url)
      end

      it "doesn't render destroy progression link" do
        render
        url = task_progression_path(@task, @progression)
        assert_select "a[data-method=\"delete\"][href=\"#{url}\"]", count: 0
      end
    end

    context "when task doesn't have a review" do
      before do
        @task = assign(:task, task)
        assign(:task_subscription, task_subscription)
      end

      it "doesn't render new review link" do
        render
        expect(rendered).not_to have_link(nil, href: task_reviews_path(@task))
      end
    end

    context "when task has a pending review" do
      before do
        @task = assign(:task, task)
        assign(:task_subscription, task_subscription)
        @review = Fabricate(:pending_review, task: @task)
      end

      it "doesn't render destroy review link" do
        render
        url = task_review_path(@task, @review)
        assert_select "a[data-method=\"delete\"][href=\"#{url}\"]", count: 0
      end

      it "doesn't render new review link" do
        render
        expect(rendered).not_to have_link(nil, href: task_reviews_path(@task))
      end

      it "doesn't render approve review link" do
        render
        url = approve_task_review_path(@task, @review)
        expect(rendered).not_to have_link(nil, href: url)
      end

      it "doesn't render disapprove review link" do
        render
        url = disapprove_task_review_path(@task, @review)
        expect(rendered).not_to have_link(nil, href: url)
      end
    end

    context "when comments" do
      before do
        @task = assign(:task, task)
        assign(:task_subscription, task_subscription)
        @comment = assign(:task_comment, @task.comments.build)
        @first_comment = Fabricate(:task_comment, task: @task)
        @second_comment =
          Fabricate(:task_comment, task: @task, user: current_user)
        @comments = assign(:comments, [@first_comment, @second_comment])
      end

      it "renders a list of comments" do
        render

        assert_select "#comment-#{@first_comment.id}"
        assert_select "#comment-#{@second_comment.id}"

        first_url = task_task_comment_path(@task, @first_comment)
        first_edit_url = edit_task_task_comment_path(@task, @first_comment)
        second_url = task_task_comment_path(@task, @second_comment)
        second_edit_url = edit_task_task_comment_path(@task, @second_comment)
        expect(rendered).not_to have_link(nil, href: first_edit_url)
        expect(rendered).to have_link(nil, href: second_edit_url)

        assert_select "a[data-method='delete'][href='#{first_url}']", count: 0
        assert_select "a[data-method='delete'][href='#{second_url}']", count: 0
      end
    end
  end
end
