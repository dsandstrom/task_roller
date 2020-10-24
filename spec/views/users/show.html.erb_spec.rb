# frozen_string_literal: true

require "rails_helper"

RSpec.describe "users/show", type: :view do
  let(:user_reporter) { Fabricate(:user_reporter) }

  context "for an admin" do
    let(:current_user) { Fabricate(:user_admin) }

    before do
      enable_pundit(view, current_user)
      @user = assign(:user, user_reporter)
    end

    it "renders attributes in #user-detail-{@user.id}" do
      render
      expect(rendered).to match(/id="user-detail-#{@user.id}"/)
      expect(rendered).to have_link(nil, href: edit_user_path(@user))
      selector = "a[href=\"#{user_path(@user)}\"][data-method='delete']"
      expect(rendered).to have_selector(:css, selector)
    end

    it "renders a list of the requested user's issues" do
      first_issue = Fabricate(:issue, user: user_reporter)
      second_issue = Fabricate(:issue, user: user_reporter)
      wrong_issue = Fabricate(:issue)

      render
      assert_select "#issue-#{wrong_issue.id}", count: 0

      [first_issue, second_issue].each do |issue|
        assert_select "#issue-#{issue.id}"
        show_url = issue_path(issue)
        expect(rendered).to have_link(nil, href: show_url)
        edit_url = edit_issue_path(issue)
        expect(rendered).to have_link(nil, href: edit_url)
      end
    end

    it "renders a list of the requested user's assigned tasks" do
      first_task = Fabricate(:task)
      first_task.assignees << user_reporter
      second_task = Fabricate(:task)
      second_task.assignees << user_reporter
      wrong_task = Fabricate(:task)

      render
      assert_select "#task-#{wrong_task.id}", count: 0

      [first_task, second_task].each do |task|
        assert_select "#task-#{task.id}"
        show_url = task_path(task)
        expect(rendered).to have_link(nil, href: show_url)
        edit_url = edit_task_path(task)
        expect(rendered).to have_link(nil, href: edit_url)
      end
    end
  end

  %w[reviewer worker reporter].each do |employee_type|
    context "for a #{employee_type}" do
      let(:current_user) { Fabricate("user_#{employee_type}") }

      before { enable_pundit(view, current_user) }

      context "when someone else" do
        before do
          @user = assign(:user, user_reporter)
        end

        it "renders attributes in #user-detail-{@user.id}" do
          render
          expect(rendered).to match(/id="user-detail-#{@user.id}"/)
          expect(rendered).not_to have_link(nil, href: edit_user_path(@user))
        end
      end

      context "when them" do
        before do
          @user = assign(:user, current_user)
        end

        it "renders attributes in #user-detail-{@user.id}" do
          render
          expect(rendered).to match(/id="user-detail-#{@user.id}"/)
          expect(rendered).to have_link(nil, href: edit_user_path(@user))
        end

        it "renders a list of the their issues" do
          first_issue = Fabricate(:issue, user: @user)
          second_issue = Fabricate(:issue, user: @user)
          wrong_issue = Fabricate(:issue)

          render
          assert_select "#issue-#{wrong_issue.id}", count: 0

          [first_issue, second_issue].each do |issue|
            assert_select "#issue-#{issue.id}"
            show_url = issue_path(issue)
            expect(rendered).to have_link(nil, href: show_url)
            edit_url = edit_issue_path(issue)
            expect(rendered).to have_link(nil, href: edit_url)
          end
        end

        it "renders a list of the their assigned tasks" do
          first_task = Fabricate(:task)
          first_task.assignees << @user
          second_task = Fabricate(:task)
          second_task.assignees << @user
          wrong_task = Fabricate(:task)

          render
          assert_select "#task-#{wrong_task.id}", count: 0

          [first_task, second_task].each do |task|
            assert_select "#task-#{task.id}"
            show_url = task_path(task)
            expect(rendered).to have_link(nil, href: show_url)
            edit_url = edit_task_path(task)
            expect(rendered).not_to have_link(nil, href: edit_url)
          end
        end
      end
    end
  end
end
