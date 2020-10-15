# frozen_string_literal: true

require "rails_helper"

RSpec.describe "tasks/show", type: :view do
  let(:admin) { Fabricate(:user_admin) }

  before(:each) { @category = assign(:category, Fabricate(:category)) }

  context "for an admin" do
    let(:admin) { Fabricate(:user_admin) }

    before do
      enable_pundit(view, admin)
      @project = assign(:project, Fabricate(:project, category: @category))
    end

    context "when project" do
      before do
        @task = assign(:task, Fabricate(:task, project: @project))
      end

      let(:url) do
        category_project_task_task_comments_url(@category, @project, @task)
      end

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

      context "task belongs to an issue" do
        let(:issue) { Fabricate(:issue, project: @project) }

        before do
          @task =
            assign(:task, Fabricate(:task, project: @project, issue: issue))
        end

        it "renders issue" do
          render
          assert_select "#task-issue-#{issue.id}"
        end
      end

      context "task assigned to a user" do
        let(:user) { Fabricate(:user_worker) }

        before do
          @task = assign(:task, Fabricate(:task, assignee_ids: [user.id]))
        end

        it "renders assignee" do
          render
          assert_select "#assignee-#{user.id}"
        end
      end

      context "when task has comments" do
        let(:user) { Fabricate(:user_worker) }

        before do
          @task = assign(:task, Fabricate(:task, assignee_ids: [user.id]))
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
        @project = assign(:project, Fabricate(:project, category: @category))
        @task = assign(:task, Fabricate(:task, project: @project))

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
        @project = assign(:project, Fabricate(:project, category: @category))
        @task = assign(:task, Fabricate(:task, project: @project))

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
        @project = assign(:project, Fabricate(:project, category: @category))
        @task = assign(:task, Fabricate(:task, project: @project))
        @task_comment = Fabricate(:task_comment, task: @task, user: user)

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
        @project = assign(:project, Fabricate(:project, category: @category))
        task = Fabricate(:task, project: @project, assignee_ids: [user.id])
        @task = assign(:task, task)

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
        @project = assign(:project, Fabricate(:project, category: @category))
        @issue = Fabricate(:issue, project: @project)
        @task =
          assign(:task, Fabricate(:task, project: @project, issue: @issue))

        @issue.destroy
        @task.reload
      end

      it "renders" do
        expect do
          render
        end.not_to raise_error
      end
    end

    # TODO: add specs for assignees, progressions, reviews
    context "when task is open" do
      before do
        @project = assign(:project, Fabricate(:project, category: @category))
        @task = assign(:task, Fabricate(:task, project: @project))
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

      it "renders new task connection link" do
        render
        expect(rendered)
          .to have_link(nil, href: new_task_connection_path(@task))
      end

      it "renders close link" do
        render
        expect(rendered).to have_link(nil, href: close_task_path(@task))
      end

      it "renders edit link" do
        render
        url = edit_category_project_task_path(@category, @project, @task)
        expect(rendered).to have_link(nil, href: url)
      end
    end

    context "when task is closed" do
      before do
        @project = assign(:project, Fabricate(:project, category: @category))
        @task = assign(:task, Fabricate(:closed_task, project: @project))
      end

      it "renders reopen link" do
        render
        expect(rendered).to have_link(nil, href: open_task_path(@task))
      end
    end

    context "when task has a source_task_connection" do
      before do
        @task = assign(:task, Fabricate(:task, project: @project))
        @task_connection = Fabricate(:task_connection, source: @task)
      end

      it "renders link to target task" do
        render
        target = @task_connection.target
        url =
          category_project_task_path(target.category, target.project, target)
        expect(rendered).to have_link(nil, href: url)
      end

      it "renders destroy link" do
        render
        url = task_connection_path(@task_connection)
        assert_select "a[data-method=\"delete\"][href=\"#{url}\"]"
      end
    end

    context "when task has target_task_connections" do
      before do
        @task = assign(:task, Fabricate(:task, project: @project))
        @task_connection = Fabricate(:task_connection, target: @task)
      end

      it "renders link to source task" do
        render
        source = @task_connection.source
        url =
          category_project_task_path(source.category, source.project, source)
        expect(rendered).to have_link(nil, href: url)
      end
    end
  end

  context "for an reviewer" do
    let(:reviewer) { Fabricate(:user_reviewer) }

    before do
      enable_pundit(view, reviewer)
      @project = assign(:project, Fabricate(:project, category: @category))
    end

    context "when task is open" do
      before do
        @task = assign(:task, Fabricate(:task, project: @project))
        @review = Fabricate(:pending_review, task: @task)
      end

      it "renders task's heading" do
        render
        assert_select ".task-heading", @task.heading
      end

      it "renders new task_comment form" do
        render

        url = category_project_task_task_comments_url(@category, @project,
                                                      @task)
        assert_select "form[action=?][method=?]", url, "post" do
          assert_select "textarea[name=?]", "task_comment[body]"
        end
      end

      it "doesn't render edit link" do
        render
        url = edit_category_project_task_path(@category, @project, @task)
        expect(rendered).not_to have_link(nil, href: url)
      end

      # TODO: authorize task reviews & connections
      # it "doesn't render approval link" do
      #   render
      #   url = approve_task_review_path(@task, @review)
      #   expect(rendered).not_to have_link(nil, href: url)
      # end
      #
      # it "doesn't render disapproval link" do
      #   render
      #   url = disapprove_task_review_path(@task, @review)
      #   expect(rendered).not_to have_link(nil, href: url)
      # end

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
      end

      it "doesn't render reopen link" do
        render
        expect(rendered).not_to have_link(nil, href: open_task_path(@task))
      end
    end

    context "when task has a source_task_connection" do
      before do
        @task = assign(:task, Fabricate(:task, project: @project))
        @task_connection = Fabricate(:task_connection, source: @task)
      end

      it "renders link to target task" do
        render
        target = @task_connection.target
        url =
          category_project_task_path(target.category, target.project, target)
        expect(rendered).to have_link(nil, href: url)
      end

      it "renders destroy link" do
        render
        url = task_connection_path(@task_connection)
        assert_select "a[data-method=\"delete\"][href=\"#{url}\"]"
      end
    end

    context "when task has target_task_connections" do
      before do
        @task = assign(:task, Fabricate(:task, project: @project))
        @task_connection = Fabricate(:task_connection, target: @task)
      end

      it "renders link to source task" do
        render
        source = @task_connection.source
        url =
          category_project_task_path(source.category, source.project, source)
        expect(rendered).to have_link(nil, href: url)
      end
    end
  end

  %w[worker reporter].each do |employee_type|
    context "for a #{employee_type}" do
      let(:current_user) { Fabricate("user_#{employee_type}") }

      before do
        enable_pundit(view, current_user)
        @project = assign(:project, Fabricate(:project, category: @category))
      end

      context "when task is open" do
        before do
          @task = assign(:task, Fabricate(:task, project: @project))
          @review = Fabricate(:pending_review, task: @task)
        end

        it "renders task's heading" do
          render
          assert_select ".task-heading", @task.heading
        end

        it "renders new task_comment form" do
          render

          url = category_project_task_task_comments_url(@category, @project,
                                                        @task)
          assert_select "form[action=?][method=?]", url, "post" do
            assert_select "textarea[name=?]", "task_comment[body]"
          end
        end

        # TODO: authorize task reviews & connections
        # it "doesn't render approval link" do
        #   render
        #   url = approve_task_review_path(@task, @review)
        #   expect(rendered).not_to have_link(nil, href: url)
        # end
        #
        # it "doesn't render disapproval link" do
        #   render
        #   url = disapprove_task_review_path(@task, @review)
        #   expect(rendered).not_to have_link(nil, href: url)
        # end

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
        end

        it "doesn't render reopen link" do
          render
          expect(rendered).not_to have_link(nil, href: open_task_path(@task))
        end
      end

      context "when their Task" do
        before do
          @task = assign(:task, Fabricate(:task, project: @project,
                                                 user: current_user))
        end

        it "renders new task_comment form" do
          render

          url = category_project_task_task_comments_url(@category, @project,
                                                        @task)
          assert_select "form[action=?][method=?]", url, "post" do
            assert_select "textarea[name=?]", "task_comment[body]"
          end
        end

        it "renders edit link" do
          render
          url = edit_category_project_task_path(@category, @project, @task)
          expect(rendered).to have_link(nil, href: url)
        end
      end

      context "when someone else's Task" do
        before do
          @task = assign(:task, Fabricate(:task, project: @project))
        end

        it "renders new task_comment form" do
          render

          url = category_project_task_task_comments_url(@category, @project,
                                                        @task)
          assert_select "form[action=?][method=?]", url, "post" do
            assert_select "textarea[name=?]", "task_comment[body]"
          end
        end

        it "doesn't render edit link" do
          render
          url = edit_category_project_task_path(@category, @project, @task)
          expect(rendered).not_to have_link(nil, href: url)
        end
      end

      context "when task has a source_task_connection" do
        before do
          @task = assign(:task, Fabricate(:task, project: @project))
          @task_connection = Fabricate(:task_connection, source: @task)
        end

        it "renders link to target task" do
          render
          target = @task_connection.target
          url =
            category_project_task_path(target.category, target.project, target)
          expect(rendered).to have_link(nil, href: url)
        end

        it "doesn't render destroy link" do
          render
          url = task_connection_path(@task_connection)
          assert_select "a[data-method=\"delete\"][href=\"#{url}\"]", count: 0
        end
      end

      context "when task has target_task_connections" do
        before do
          @task = assign(:task, Fabricate(:task, project: @project))
          @task_connection = Fabricate(:task_connection, target: @task)
        end

        it "renders link to source task" do
          render
          source = @task_connection.source
          url =
            category_project_task_path(source.category, source.project, source)
          expect(rendered).to have_link(nil, href: url)
        end
      end
    end
  end
end
