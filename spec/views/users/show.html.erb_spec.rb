# frozen_string_literal: true

require "rails_helper"

RSpec.describe "users/show", type: :view do
  let(:user_reporter) { Fabricate(:user_reporter) }

  context "for an admin" do
    let(:current_user) { Fabricate(:user_admin) }
    let(:first_task) { Fabricate(:task) }
    let(:second_task) { Fabricate(:task) }
    let(:first_issue) { Fabricate(:issue) }
    let(:second_issue) { Fabricate(:issue) }

    before(:each) do
      @user = assign(:user, user_reporter)
      assign(:issues, [first_issue, second_issue])
      assign(:tasks, [first_task, second_task])
      enable_pundit(view, current_user)
    end

    it "renders attributes in #user-detail-{@user.id}" do
      render
      expect(rendered).to match(/id="user-detail-#{@user.id}"/)
      expect(rendered).to have_link(nil, href: edit_user_path(@user))
      selector = "a[href=\"#{user_path(@user)}\"][data-method='delete']"
      expect(rendered).to have_selector(:css, selector)
    end

    it "renders a list of tasks" do
      render
      assert_select "#task-#{first_task.id}"
      assert_select "#task-#{second_task.id}"
    end

    it "renders a list of issues" do
      render
      assert_select "#issue-#{first_issue.id}"
      assert_select "#issue-#{second_issue.id}"
    end
  end

  %w[reviewer worker reporter].each do |employee_type|
    context "for a #{employee_type}" do
      let(:current_user) { Fabricate("user_#{employee_type}") }

      before { enable_pundit(view, current_user) }

      context "when someone else" do
        before do
          @user = assign(:user, user_reporter)
          assign(:issues, [])
          assign(:tasks, [])
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
          assign(:issues, [])
          assign(:tasks, [])
        end

        it "renders attributes in #user-detail-{@user.id}" do
          render
          expect(rendered).to match(/id="user-detail-#{@user.id}"/)
          expect(rendered).to have_link(nil, href: edit_user_path(@user))
        end
      end
    end
  end
end
