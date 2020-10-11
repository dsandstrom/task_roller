# frozen_string_literal: true

require "rails_helper"

RSpec.describe "issues/show", type: :view do
  before(:each) { @category = assign(:category, Fabricate(:category)) }

  context "for an admin" do
    let(:admin) { Fabricate(:user_admin) }

    before { enable_pundit(view, admin) }

    context "when project" do
      before do
        @project = assign(:project, Fabricate(:project, category: @category))
        @issue = assign(:issue, Fabricate(:issue, project: @project))
        @comment = assign(:issue_comment, @issue.comments.build)
        @comments = assign(:comments, [])
      end

      let(:url) do
        category_project_issue_issue_comments_url(@category, @project, @issue)
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

      it "renders edit link" do
        render

        url = edit_category_project_issue_path(@category, @project, @issue)
        expect(rendered).to have_link(nil, href: url)
      end

      context "with tasks" do
        it "renders a list of tasks" do
          task = Fabricate(:task, issue: @issue)

          render
          assert_select "#task-#{task.id}"
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

      it "renders" do
        expect do
          render
        end.not_to raise_error
      end
    end
  end

  %w[reviewer worker reporter].each do |employee_type|
    context "for a #{employee_type}" do
      let(:current_user) { Fabricate("user_#{employee_type}") }

      before { enable_pundit(view, current_user) }

      before do
        @project = assign(:project, Fabricate(:project, category: @category))
      end

      context "when their issue" do
        let(:url) do
          category_project_issue_issue_comments_url(@category, @project, @issue)
        end
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

          url = edit_category_project_issue_path(@category, @project, @issue)
          expect(rendered).to have_link(nil, href: url)
        end
      end

      context "when someone else's issue" do
        let(:url) do
          category_project_issue_issue_comments_url(@category, @project, @issue)
        end

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

          url = edit_category_project_issue_path(@category, @project, @issue)
          expect(rendered).not_to have_link(nil, href: url)
        end
      end
    end
  end
end
