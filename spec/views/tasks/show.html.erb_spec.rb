# frozen_string_literal: true

# TODO: test invisible and internal tasks

require "rails_helper"

RSpec.describe "tasks/show", type: :view do
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:task) { Fabricate(:task, project: project) }
  let(:closed_task) { Fabricate(:closed_task, project: project) }

  before(:each) { @category = assign(:category, category) }

  context "for an admin" do
    let(:admin) { Fabricate(:user_admin) }
    let(:task_subscription) do
      Fabricate(:task_subscription, task: task, user: admin)
    end

    before do
      enable_can(view, admin)
      assign(:comments, [])
      assign(:assignees, [])
      assign(:assigned, [])
      assign(:progressions, [])
      assign(:duplicates, [])
      assign(:source_connection, Fabricate(:task_connection))
      assign(:subscription, task_subscription)
      assign(:user, task.user)
      assign(:siblings, nil)
    end

    context "when project" do
      before { @task = assign(:task, task) }

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

      it "renders edit task assignments link" do
        render
        expect(rendered).to have_link(nil, href: edit_assignment_path(@task))
      end
    end

    context "when task belongs to an issue" do
      let(:issue) { Fabricate(:issue, project: project) }

      before do
        @task =
          assign(:task, Fabricate(:task, project: project, issue: issue))
      end

      it "renders issue" do
        render
        assert_select "#issue-#{issue.id}"
      end
    end

    context "when task assigned to a user" do
      let(:user) { Fabricate(:user_worker) }

      before do
        @task = assign(:task, task)
        Fabricate(:task_assignee, task: @task, assignee: user)
        assign(:assignees, [user])
        assign(:assigned, [])
      end

      it "renders assignee" do
        render
        assert_select "#assignee-#{user.id}"
        expect(rendered).to have_link(nil, href: user_assignments_path(user))
      end

      it "renders edit task assignments link" do
        render
        expect(rendered).to have_link(nil, href: edit_assignment_path(@task))
      end
    end

    context "when task has comments" do
      let(:user) { Fabricate(:user_worker) }

      before do
        @task = assign(:task, task)
        Fabricate(:task_assignee, task: @task, assignee: user)
        @task_comment = Fabricate(:task_comment, task: @task)
        assign(:comments, [@task_comment])
      end

      it "renders them" do
        render
        assert_select "#comment-#{@task_comment.id}"
      end
    end

    context "when task is open" do
      let(:task) { Fabricate(:task) }

      before { @task = assign(:task, task) }

      it "renders close link" do
        render
        url = task_closures_path(@task)
        assert_select "a[href='#{url}'][data-method='post']"
      end
    end

    context "when no task_type" do
      before do
        @task = assign(:task, task)

        @task.task_type.destroy
        @task.reload
      end

      it "renders heading" do
        render
        assert_select ".task-heading", @task.heading
      end
    end

    context "when task user" do
      before do
        @task = assign(:task, task)
        @user = assign(:user, @task.user)
      end

      it "renders link to user tasks" do
        render
        expect(rendered).to have_link(nil, href: user_tasks_path(@user))
      end
    end

    context "when task's user destroyed" do
      before do
        @task = assign(:task, task)
        @user = assign(:user, nil)
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
        assign(:comments, [@task_comment])

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
        assign(:user, @task.user)
        Fabricate(:task_assignee, task: @task, assignee: user)
        assign(:assignees, [user])

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
        @issue = Fabricate(:issue, project: project)
        @task = assign(:task, Fabricate(:task, project: project, issue: @issue))

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
        @review = assign(:review, Fabricate(:pending_review, task: @task))
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

      it "doesn't render close link" do
        render
        expect(rendered).not_to have_link(nil, href: task_closures_path(@task))
      end

      it "doesn't render edit task assignments link" do
        render
        expect(rendered)
          .not_to have_link(nil, href: edit_assignment_path(@task))
      end
    end

    context "when task doesn't have a source_connection" do
      before do
        @task = assign(:task, task)
      end

      it "renders new task connection link" do
        render
        expect(rendered)
          .to have_link(nil, href: new_task_connection_path(@task))
      end
    end

    context "when task is closed without approved review nor duplicate" do
      let(:task) { Fabricate(:closed_task) }

      before do
        @task = assign(:task, task)
      end

      it "renders reopen link" do
        render
        url = task_reopenings_path(@task)
        assert_select "a[href='#{url}'][data-method='post']"
      end

      it "doesn't render edit task assignments link" do
        render
        expect(rendered)
          .not_to have_link(nil, href: edit_assignment_path(@task))
      end
    end

    context "when task is closed with source_connection" do
      before do
        @task = assign(:task, closed_task)
        @source_connection =
          assign(:source_connection, Fabricate(:task_connection, source: @task))
      end

      it "renders link to target task" do
        render
        target = @source_connection.target
        url = task_path(target)
        expect(rendered).to have_link(nil, href: url)
      end

      it "renders destroy link" do
        render
        url = task_connection_path(@source_connection)
        assert_select "a[data-method=\"delete\"][href=\"#{url}\"]"
      end

      it "doesn't render a new task connection link" do
        render
        expect(rendered)
          .not_to have_link(nil, href: new_task_connection_path(@task))
      end

      it "doesn't render close link" do
        render
        expect(rendered).not_to have_link(nil, href: task_closures_path(@task))
      end

      it "doesn't render reopen link" do
        render
        expect(rendered)
          .not_to have_link(nil, href: task_reopenings_path(@task))
      end

      it "doesn't render edit task assignments link" do
        render
        expect(rendered)
          .not_to have_link(nil, href: edit_assignment_path(@task))
      end
    end

    context "when task is closed with approved review" do
      before do
        @task = assign(:task, closed_task)
        assign(:user, @task.user)
        @review = assign(:review, Fabricate(:approved_review, task: @task))
      end

      it "doesn't render a new task connection link" do
        render
        expect(rendered)
          .not_to have_link(nil, href: new_task_connection_path(@task))
      end

      it "doesn't render close link" do
        render
        expect(rendered).not_to have_link(nil, href: task_closures_path(@task))
      end

      it "renders reopen link" do
        render
        expect(rendered).to have_link(nil, href: task_reopenings_path(@task))
      end

      it "doesn't render destroy review link" do
        render
        url = task_review_path(@task, @review)
        assert_select "a[data-method=\"delete\"][href=\"#{url}\"]", count: 0
      end

      it "doesn't render edit task assignments link" do
        render
        expect(rendered)
          .not_to have_link(nil, href: edit_assignment_path(@task))
      end
    end

    context "when task is closed with disapproved review" do
      before do
        @task = assign(:task, closed_task)
        assign(:user, @task.user)
        @review = assign(:review, Fabricate(:disapproved_review, task: @task))
      end

      it "renders reopen link" do
        render
        expect(rendered).to have_link(nil, href: task_reopenings_path(@task))
      end

      it "doesn't render destroy review link" do
        render
        url = task_review_path(@task, @review)
        assert_select "a[data-method=\"delete\"][href=\"#{url}\"]", count: 0
      end

      it "doesn't render edit task assignments link" do
        render
        expect(rendered)
          .not_to have_link(nil, href: edit_assignment_path(@task))
      end
    end

    context "when task is open with disapproved review" do
      before do
        @task = assign(:task, task)
        assign(:user, @task.user)
        @review = assign(:review, Fabricate(:disapproved_review, task: @task))
      end

      it "renders close link" do
        render
        expect(rendered).to have_link(nil, href: task_closures_path(@task))
      end

      it "doesn't render reopen link" do
        render
        expect(rendered)
          .not_to have_link(nil, href: task_reopenings_path(@task))
      end

      it "doesn't render destroy review link" do
        render
        url = task_review_path(@task, @review)
        assert_select "a[data-method=\"delete\"][href=\"#{url}\"]", count: 0
      end

      it "renders edit task assignments link" do
        render
        expect(rendered).to have_link(nil, href: edit_assignment_path(@task))
      end
    end

    context "when task has target_connections" do
      before do
        @task = assign(:task, task)
        assign(:user, @task.user)
        @target_connection = Fabricate(:task_connection, target: @task)
        assign(:duplicates, [@target_connection.source])
      end

      it "renders link to source task" do
        render
        source = @target_connection.source
        url = task_path(source)
        expect(rendered).to have_link(nil, href: url)
      end
    end

    context "when an unfinished progression" do
      before do
        @task = assign(:task, task)
        @user = assign(:user, @task.user)
        @task.assignees << @user
        assign(:assignees, [@user])
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
        @user = assign(:user, @task.user)
        @task.assignees << @task.user
        assign(:assignees, [@user])
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
        @task.assignees << @task.user
        assign(:assignees, [@task.user])
      end

      it "doesn't render new review link" do
        render
        expect(rendered).not_to have_link(nil, href: task_reviews_path(@task))
      end
    end

    context "when a pending review" do
      before do
        @task = assign(:task, task)
        @user = assign(:user, @task.user)
        @task.assignees << @task.user
        assign(:assignees, [@user])
        @review = assign(:review, Fabricate(:pending_review, task: @task))
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

      it "doesn't render close link" do
        render
        expect(rendered).not_to have_link(nil, href: task_closures_path(@task))
      end
    end

    context "when comments" do
      before do
        @task = assign(:task, task)
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

    context "when task has a sibling" do
      before do
        @task = assign(:task, task)
        @sibling = Fabricate(:task, issue: @task.issue)
        assign(:siblings, [@sibling])
      end

      it "renders a list of related tasks" do
        render

        assert_select "#task-#{@sibling.id}"
      end
    end

    context "when task project is invisible" do
      let(:project) { Fabricate(:invisible_project, category: category) }
      let(:form_url) { task_task_comments_url(@task) }

      before { @task = assign(:task, task) }

      it "renders edit link" do
        render
        url = edit_task_path(@task)
        expect(rendered).to have_link(nil, href: url)
      end

      it "doesn't render new task_comment form" do
        render

        assert_select "form[action=?]", form_url, count: 0
      end

      it "renders edit task assignments link" do
        render
        expect(rendered).to have_link(nil, href: edit_assignment_path(@task))
      end

      it "renders close link" do
        render
        url = task_closures_path(@task)
        assert_select "a[href='#{url}'][data-method='post']"
      end

      it "renders a new task connection link" do
        render
        expect(rendered)
          .to have_link(nil, href: new_task_connection_path(@task))
      end

      context "and assigned to a user" do
        let(:user) { Fabricate(:user_worker) }

        before do
          Fabricate(:task_assignee, task: @task, assignee: user)
          assign(:assignees, [user])
          assign(:assigned, [])
        end

        it "renders assignee" do
          render
          assert_select "#assignee-#{user.id}"
        end

        it "renders edit task assignments link" do
          render
          expect(rendered).to have_link(nil, href: edit_assignment_path(@task))
        end
      end

      context "and in review" do
        before do
          @review = assign(:review, Fabricate(:pending_review, task: @task))
        end

        it "renders approval link" do
          render
          url = approve_task_review_path(@task, @review)
          expect(rendered).to have_link(nil, href: url)
        end

        it "renders disapproval link" do
          render
          url = disapprove_task_review_path(@task, @review)
          expect(rendered).to have_link(nil, href: url)
        end
      end

      context "and is closed with approved review" do
        before do
          @task = assign(:task, closed_task)
          @review = assign(:review, Fabricate(:approved_review, task: @task))
        end

        it "renders reopen link" do
          render
          expect(rendered).to have_link(nil, href: task_reopenings_path(@task))
        end
      end

      context "and is closed with source_connection" do
        before do
          @task = assign(:task, closed_task)
          task_connection = Fabricate(:task_connection, source: @task)
          @source_connection = assign(:source_connection, task_connection)
        end

        it "renders link to target task" do
          render
          target = @source_connection.target
          url = task_path(target)
          expect(rendered).to have_link(nil, href: url)
        end

        it "renders destroy link" do
          render
          url = task_connection_path(@source_connection)
          assert_select "a[data-method=\"delete\"][href=\"#{url}\"]"
        end
      end
    end

    context "when task project is internal" do
      let(:project) { Fabricate(:internal_project, category: category) }
      let(:form_url) { task_task_comments_url(@task) }

      before { @task = assign(:task, task) }

      it "renders edit link" do
        render
        url = edit_task_path(@task)
        expect(rendered).to have_link(nil, href: url)
      end

      it "renders new task_comment form" do
        render

        assert_select "form[action=?][method=?]", form_url, "post"
      end

      it "renders edit task assignments link" do
        render
        expect(rendered).to have_link(nil, href: edit_assignment_path(@task))
      end

      it "renders close link" do
        render
        url = task_closures_path(@task)
        assert_select "a[href='#{url}'][data-method='post']"
      end

      it "renders a new task connection link" do
        render
        expect(rendered)
          .to have_link(nil, href: new_task_connection_path(@task))
      end

      context "and assigned to a user" do
        let(:user) { Fabricate(:user_worker) }

        before do
          Fabricate(:task_assignee, task: @task, assignee: user)
          assign(:assignees, [user])
          assign(:assigned, [])
        end

        it "renders assignee" do
          render
          assert_select "#assignee-#{user.id}"
        end

        it "renders edit task assignments link" do
          render
          expect(rendered).to have_link(nil, href: edit_assignment_path(@task))
        end
      end

      context "and in review" do
        before do
          @review = assign(:review, Fabricate(:pending_review, task: @task))
        end

        it "renders approval link" do
          render
          url = approve_task_review_path(@task, @review)
          expect(rendered).to have_link(nil, href: url)
        end

        it "renders disapproval link" do
          render
          url = disapprove_task_review_path(@task, @review)
          expect(rendered).to have_link(nil, href: url)
        end
      end

      context "and is closed with approved review" do
        before do
          @task = assign(:task, closed_task)
          @review = assign(:review, Fabricate(:approved_review, task: @task))
        end

        it "renders reopen link" do
          render
          expect(rendered).to have_link(nil, href: task_reopenings_path(@task))
        end
      end

      context "and is closed with source_connection" do
        before do
          @task = assign(:task, closed_task)
          task_connection = Fabricate(:task_connection, source: @task)
          @source_connection = assign(:source_connection, task_connection)
        end

        it "renders link to target task" do
          render
          target = @source_connection.target
          url = task_path(target)
          expect(rendered).to have_link(nil, href: url)
        end

        it "renders destroy link" do
          render
          url = task_connection_path(@source_connection)
          assert_select "a[data-method=\"delete\"][href=\"#{url}\"]"
        end
      end
    end
  end

  context "for a reviewer" do
    let(:reviewer) { Fabricate(:user_reviewer) }
    let(:task_subscription) do
      Fabricate(:task_subscription, task: task, user: reviewer)
    end

    before do
      enable_can(view, reviewer)
      assign(:comments, [])
      assign(:assignees, [])
      assign(:assigned, [])
      assign(:progressions, [])
      assign(:duplicates, [])
      assign(:source_connection, Fabricate(:task_connection))
      assign(:subscription, task_subscription)
      assign(:user, task.user)
      assign(:siblings, nil)
    end

    context "when task is open" do
      before do
        @task = assign(:task, task)
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

      it "renders edit task assignments link" do
        render
        expect(rendered).to have_link(nil, href: edit_assignment_path(@task))
      end
    end

    context "when task assigned to a user" do
      let(:user) { Fabricate(:user_worker) }

      before do
        @task = assign(:task, task)
        Fabricate(:task_assignee, task: @task, assignee: user)
        assign(:assignees, [user])
        assign(:assigned, [])
      end

      it "renders assignee" do
        render
        assert_select "#assignee-#{user.id}"
        expect(rendered).to have_link(nil, href: user_assignments_path(user))
      end

      it "renders edit task assignments link" do
        render
        expect(rendered).to have_link(nil, href: edit_assignment_path(@task))
      end
    end

    context "when task has a source_connection" do
      before do
        @task = assign(:task, task)
        @source_connection = assign(:source_connection,
                                    Fabricate(:task_connection, source: @task))
      end

      it "renders link to target task" do
        render
        target = @source_connection.target
        url = task_path(target)
        expect(rendered).to have_link(nil, href: url)
      end

      it "renders destroy link" do
        render
        url = task_connection_path(@source_connection)
        assert_select "a[data-method=\"delete\"][href=\"#{url}\"]"
      end
    end

    context "when task has target_connections" do
      before do
        @task = assign(:task, task)
        @target_connection = Fabricate(:task_connection, target: @task)
        assign(:duplicates, [@target_connection.source])
      end

      it "renders link to source task" do
        render
        source = @target_connection.source
        url = task_path(source)
        expect(rendered).to have_link(nil, href: url)
      end
    end

    context "when an unfinished progression" do
      before do
        @task = assign(:task, task)
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
        @task.assignees << @task.user
        assign(:assignees, [@task.user])
        @review = assign(:review, Fabricate(:pending_review, task: @task))
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
        @first_comment = Fabricate(:task_comment, task: @task)
        @second_comment = Fabricate(:task_comment, task: @task, user: reviewer)
        assign(:comments, [@first_comment, @second_comment])
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

    context "when closures" do
      before do
        @task = assign(:task, task)

        @closure = Fabricate(:task_closure, task: task)
      end

      it "renders list of closures" do
        render
        assert_select "#task-closure-#{@closure.id}"
      end
    end

    context "when reopenings" do
      before do
        @task = assign(:task, task)

        @reopening = Fabricate(:task_reopening, task: task)
      end

      it "renders list of reopenings" do
        render
        assert_select "#task-reopening-#{@reopening.id}"
      end
    end

    context "when not subscribed to the task" do
      before do
        @task = assign(:task, task)
        assign(:subscription,
               Fabricate.build(:task_subscription, task: @task, user: reviewer))
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
        @subscription = assign(:subscription, task_subscription)
      end

      it "doesn't render new task_subscription link" do
        render
        url = task_task_subscriptions_path(@task)
        expect(rendered).not_to have_link(nil, href: url)
      end

      it "renders destroy task_subscription link" do
        render
        url = task_task_subscription_path(@task, @subscription)
        assert_select "a[data-method='delete'][href='#{url}']"
      end
    end

    context "when someone else's task" do
      context "is open" do
        before do
          @task = assign(:task, Fabricate(:open_task, project: project))
        end

        it "doesn't render reopen link" do
          render
          expect(rendered)
            .not_to have_link(nil, href: task_reopenings_path(@task))
        end

        it "doesn't render close link" do
          render
          expect(rendered)
            .not_to have_link(nil, href: task_closures_path(@task))
        end
      end

      context "when task is closed" do
        before do
          @task = assign(:task, Fabricate(:closed_task, project: project))
        end

        it "renders reopen link" do
          render
          expect(rendered).to have_link(nil, href: task_reopenings_path(@task))
        end

        it "doesn't render close link" do
          render
          expect(rendered)
            .not_to have_link(nil, href: task_closures_path(@task))
        end
      end
    end

    context "when their task" do
      context "is open" do
        let(:task) { Fabricate(:task, user: reviewer) }

        before do
          @task = assign(:task, task)
        end

        it "renders close link" do
          render
          expect(rendered).to have_link(nil, href: task_closures_path(@task))
        end
      end

      context "is closed" do
        let(:task) { Fabricate(:closed_task, user: reviewer) }

        before do
          @task = assign(:task, task)
        end

        context "without a duplicate" do
          it "doesn't render close link" do
            render
            expect(rendered)
              .not_to have_link(nil, href: task_closures_path(@task))
          end

          it "renders open link" do
            render
            expect(rendered)
              .to have_link(nil, href: task_reopenings_path(@task))
          end
        end

        context "with a duplicate" do
          let(:source_connection) { Fabricate(:task_connection, source: task) }

          before do
            @source_connection = assign(:source_connection, source_connection)
          end

          it "doesn't render close link" do
            render
            expect(rendered)
              .not_to have_link(nil, href: task_closures_path(@task))
          end

          it "doesn't render open link" do
            render
            expect(rendered)
              .not_to have_link(nil, href: task_reopenings_path(@task))
          end
        end
      end
    end

    context "when task project is invisible" do
      let(:project) { Fabricate(:invisible_project, category: category) }
      let(:task) { Fabricate(:task, project: project, user: reviewer) }
      let(:closed_task) do
        Fabricate(:closed_task, project: project, user: reviewer)
      end

      context "and their task" do
        let(:task) { Fabricate(:task, project: project, user: reviewer) }

        before do
          @task = assign(:task, task)
        end

        it "doesn't render edit link" do
          render
          url = edit_task_path(@task)
          expect(rendered).not_to have_link(nil, href: url)
        end

        it "doesn't render new task_comment form" do
          render

          form_url = task_task_comments_url(@task)
          assert_select "form[action=?]", form_url, count: 0
        end

        it "doesn't render edit task assignments link" do
          render
          expect(rendered)
            .not_to have_link(nil, href: edit_assignment_path(@task))
        end

        it "doesn't render close link" do
          render
          url = task_closures_path(@task)
          expect(rendered).not_to have_link(nil, href: url)
        end

        it "doesn't render a new task connection link" do
          render
          expect(rendered)
            .not_to have_link(nil, href: new_task_connection_path(@task))
        end
      end

      context "and assigned to a user" do
        let(:user) { Fabricate(:user_worker) }

        before do
          @task = assign(:task, task)
          Fabricate(:task_assignee, task: @task, assignee: user)
          assign(:assignees, [user])
          assign(:assigned, [])
        end

        it "renders assignee" do
          render
          assert_select "#assignee-#{user.id}"
        end

        it "doesn't render edit task assignments link" do
          render
          expect(rendered)
            .not_to have_link(nil, href: edit_assignment_path(@task))
        end
      end

      context "and in review" do
        before do
          @task = assign(:task, task)
          @review = assign(:review, Fabricate(:pending_review, task: @task))
        end

        it "doesn't render approval link" do
          render
          url = approve_task_review_path(@task, @review)
          expect(rendered).not_to have_link(nil, href: url)
        end

        it "doesn't render disapproval link" do
          render
          url = disapprove_task_review_path(@task, @review)
          expect(rendered).not_to have_link(nil, href: url)
        end
      end

      context "and is closed with approved review" do
        before do
          @task = assign(:task, closed_task)
          @review = assign(:review, Fabricate(:approved_review, task: @task))
        end

        it "doesn't render reopen link" do
          render
          expect(rendered)
            .not_to have_link(nil, href: task_reopenings_path(@task))
        end
      end

      context "and is closed with source_connection" do
        before do
          @task = assign(:task, closed_task)
          task_connection = Fabricate(:task_connection, source: @task)
          @source_connection = assign(:source_connection, task_connection)
        end

        it "renders link to target task" do
          render
          target = @source_connection.target
          url = task_path(target)
          expect(rendered).to have_link(nil, href: url)
        end

        it "doesn't render destroy link" do
          render
          url = task_connection_path(@source_connection)
          expect(rendered).not_to have_link(nil, href: url)
        end
      end

      context "when not subscribed to the task" do
        let(:subscription) do
          Fabricate.build(:task_subscription, task: @task, user: reviewer)
        end

        before do
          @task = assign(:task, task)
          assign(:subscription, subscription)
        end

        it "doesn't render new task_subscription link" do
          render
          expect(rendered)
            .not_to have_link(nil, href: task_task_subscriptions_path(@task))
        end
      end

      context "when subscribed to the task" do
        before do
          @task = assign(:task, task)
          @subscription = assign(:subscription, task_subscription)
        end

        it "doesn't render destroy task_subscription link" do
          render
          url = task_task_subscription_path(@task, @subscription)
          expect(rendered).not_to have_link(nil, href: url)
        end
      end
    end

    context "when task project is internal" do
      let(:project) { Fabricate(:internal_project, category: category) }
      let(:task) { Fabricate(:task, project: project, user: reviewer) }
      let(:closed_task) do
        Fabricate(:closed_task, project: project, user: reviewer)
      end

      context "and their task" do
        let(:task) { Fabricate(:task, project: project, user: reviewer) }

        before do
          @task = assign(:task, task)
        end

        it "renders edit link" do
          render
          url = edit_task_path(@task)
          expect(rendered).to have_link(nil, href: url)
        end

        it "renders new task_comment form" do
          render

          form_url = task_task_comments_url(@task)
          assert_select "form[action=?][method=?]", form_url, "post"
        end

        it "renders edit task assignments link" do
          render
          expect(rendered).to have_link(nil, href: edit_assignment_path(@task))
        end

        it "renders close link" do
          render
          url = task_closures_path(@task)
          assert_select "a[href='#{url}'][data-method='post']"
        end

        it "renders a new task connection link" do
          render
          expect(rendered)
            .to have_link(nil, href: new_task_connection_path(@task))
        end
      end

      context "and assigned to a user" do
        let(:user) { Fabricate(:user_worker) }

        before do
          @task = assign(:task, task)
          Fabricate(:task_assignee, task: @task, assignee: user)
          assign(:assignees, [user])
          assign(:assigned, [])
        end

        it "renders assignee" do
          render
          assert_select "#assignee-#{user.id}"
        end

        it "renders edit task assignments link" do
          render
          expect(rendered).to have_link(nil, href: edit_assignment_path(@task))
        end
      end

      context "and in review" do
        before do
          @task = assign(:task, task)
          @review = assign(:review, Fabricate(:pending_review, task: @task))
        end

        it "renders approval link" do
          render
          url = approve_task_review_path(@task, @review)
          expect(rendered).to have_link(nil, href: url)
        end

        it "renders disapproval link" do
          render
          url = disapprove_task_review_path(@task, @review)
          expect(rendered).to have_link(nil, href: url)
        end
      end

      context "and is closed with approved review" do
        before do
          @task = assign(:task, closed_task)
          @review = assign(:review, Fabricate(:approved_review, task: @task))
        end

        it "renders reopen link" do
          render
          expect(rendered).to have_link(nil, href: task_reopenings_path(@task))
        end
      end

      context "and is closed with source_connection" do
        before do
          @task = assign(:task, closed_task)
          task_connection = Fabricate(:task_connection, source: @task)
          @source_connection = assign(:source_connection, task_connection)
        end

        it "renders link to target task" do
          render
          target = @source_connection.target
          url = task_path(target)
          expect(rendered).to have_link(nil, href: url)
        end

        it "renders destroy link" do
          render
          url = task_connection_path(@source_connection)
          assert_select "a[data-method=\"delete\"][href=\"#{url}\"]"
        end
      end

      context "when not subscribed to the task" do
        let(:subscription) do
          Fabricate.build(:task_subscription, task: @task, user: reviewer)
        end

        before do
          @task = assign(:task, task)
          assign(:subscription, subscription)
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
          @subscription = assign(:subscription, task_subscription)
        end

        it "doesn't render new task_subscription link" do
          render
          url = task_task_subscriptions_path(@task)
          expect(rendered).not_to have_link(nil, href: url)
        end

        it "renders destroy task_subscription link" do
          render
          url = task_task_subscription_path(@task, @subscription)
          assert_select "a[data-method='delete'][href='#{url}']"
        end
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
      assign(:comments, [])
      assign(:assignees, [])
      assign(:assigned, [])
      assign(:progressions, [])
      assign(:duplicates, [])
      assign(:source_connection, Fabricate(:task_connection))
      assign(:subscription, task_subscription)
      assign(:siblings, nil)
    end

    context "when task is open" do
      before do
        @task = assign(:task, task)
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

      it "renders close link" do
        render
        expect(rendered).not_to have_link(nil, href: task_closures_path(@task))
      end
    end

    context "when task is closed" do
      before do
        @task = assign(:task, Fabricate(:closed_task, project: project))
      end

      it "doesn't render reopen link" do
        render
        expect(rendered)
          .not_to have_link(nil, href: task_reopenings_path(@task))
      end
    end

    context "when Task assigned to them" do
      before do
        @task = assign(:task, task)
        @task.assignees << current_user
        assign(:assignees, [current_user])
      end

      context "and they have an unfinished progression" do
        before do
          @progression = Fabricate(:unfinished_progression, user: current_user,
                                                            task: @task)
          @progressions = assign(:progressions, [@progression])
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

        it "doesn't render edit task assignments link" do
          render
          expect(rendered)
            .not_to have_link(nil, href: edit_assignment_path(@task))
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
          @review = assign(:review, Fabricate(:pending_review, task: @task))
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
        @task.assignees << @task.user
        @assignees = assign(:assignees, [@task.user])
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

      it "doesn't render edit task assignments link" do
        render
        expect(rendered)
          .not_to have_link(nil, href: edit_assignment_path(@task))
      end

      context "with no review" do
        it "doesn't render new review link" do
          render
          expect(rendered).not_to have_link(nil, href: task_reviews_path(@task))
        end
      end

      context "with a pending review" do
        before do
          @review = assign(:review, Fabricate(:pending_review, task: @task))
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
        @source_connection = assign(:source_connection,
                                    Fabricate(:task_connection, source: @task))
      end

      it "renders link to target task" do
        render
        target = @source_connection.target
        url = task_path(target)
        expect(rendered).to have_link(nil, href: url)
      end

      it "doesn't render destroy link" do
        render
        url = task_connection_path(@source_connection)
        assert_select "a[data-method=\"delete\"][href=\"#{url}\"]", count: 0
      end
    end

    context "when task has target_connections" do
      before do
        @task = assign(:task, task)
        @target_connection = Fabricate(:task_connection, target: @task)
        assign(:duplicates, [@target_connection.source])
      end

      it "renders link to source task" do
        render
        source = @target_connection.source
        url = task_path(source)
        expect(rendered).to have_link(nil, href: url)
      end
    end

    context "when a pending review" do
      before do
        @task = assign(:task, task)
        @task.assignees << @task.user
        assign(:assignees, [@task.user])
        @review = assign(:review, Fabricate(:pending_review, task: @task))
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
        @first_comment = Fabricate(:task_comment, task: @task)
        @second_comment =
          Fabricate(:task_comment, task: @task, user: current_user)
        assign(:comments, [@first_comment, @second_comment])
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

    context "when their task" do
      let(:task) { Fabricate(:task, user: current_user) }

      before { @task = assign(:task, task) }

      it "doesn't render close link" do
        render
        expect(rendered).not_to have_link(nil, href: task_closures_path(@task))
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
      assign(:comments, [])
      assign(:assignees, [])
      assign(:assigned, [])
      assign(:progressions, [])
      assign(:duplicates, [])
      assign(:source_connection, Fabricate(:task_connection))
      assign(:subscription, task_subscription)
      assign(:user, task.user)
      assign(:siblings, nil)
    end

    context "when task is open" do
      before { @task = assign(:task, task) }

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
        expect(rendered).not_to have_link(nil, href: task_closures_path(@task))
      end

      it "doesn't render edit link" do
        render
        url = edit_task_path(@task)
        expect(rendered).not_to have_link(nil, href: url)
      end
    end

    context "when task is closed" do
      before do
        @task = assign(:task, Fabricate(:closed_task, project: project))
      end

      it "doesn't render reopen link" do
        render
        expect(rendered)
          .not_to have_link(nil, href: task_reopenings_path(@task))
      end
    end

    context "when task has a source_connection" do
      before do
        @task = assign(:task, task)
        @source_connection = assign(:source_connection,
                                    Fabricate(:task_connection, source: @task))
      end

      it "renders link to target task" do
        render
        target = @source_connection.target
        url = task_path(target)
        expect(rendered).to have_link(nil, href: url)
      end

      it "doesn't render destroy link" do
        render
        url = task_connection_path(@source_connection)
        assert_select "a[data-method=\"delete\"][href=\"#{url}\"]", count: 0
      end
    end

    context "when task has target_connections" do
      before do
        @task = assign(:task, task)
        @target_connection = Fabricate(:task_connection, target: @task)
        assign(:duplicates, [@target_connection.source])
      end

      it "renders link to source task" do
        render
        source = @target_connection.source
        url = task_path(source)
        expect(rendered).to have_link(nil, href: url)
      end
    end

    context "when task has an unfinished progression" do
      before do
        @task = assign(:task, task)
        @task.assignees << @task.user
        assign(:assignees, [@task.user])
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

      it "doesn't render edit task assignments link" do
        render
        expect(rendered)
          .not_to have_link(nil, href: edit_assignment_path(@task))
      end
    end

    context "when task has a finished progression" do
      before do
        @task = assign(:task, task)
        @task.assignees << @task.user
        @assignees = assign(:assignees, [@task.user])
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
      before { @task = assign(:task, task) }

      it "doesn't render new review link" do
        render
        expect(rendered).not_to have_link(nil, href: task_reviews_path(@task))
      end
    end

    context "when task has a pending review" do
      before do
        @task = assign(:task, task)
        @review = assign(:review, Fabricate(:pending_review, task: @task))
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
        @first_comment = Fabricate(:task_comment, task: @task)
        @second_comment =
          Fabricate(:task_comment, task: @task, user: current_user)
        assign(:comments, [@first_comment, @second_comment])
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

    context "when their task" do
      let(:task) { Fabricate(:task, user: current_user) }

      before { @task = assign(:task, task) }

      it "doesn't render close link" do
        render
        expect(rendered).not_to have_link(nil, href: task_closures_path(@task))
      end
    end
  end
end
