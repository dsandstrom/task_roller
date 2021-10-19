# frozen_string_literal: true

require "rails_helper"

RSpec.describe "users/edit", type: :view do
  let(:subject) { "users/edit" }
  let(:reporter) { Fabricate(:user_reporter) }

  context "for an admin" do
    let(:current_user) { Fabricate(:user_admin) }

    before { enable_can(view, current_user) }

    context "when editing a reporter" do
      before { @user = assign(:user, reporter) }

      it "renders the edit user form" do
        render

        assert_select "form[action=?][method=?]", user_path(@user), "post" do
          assert_select "input[name=?]", "user[name]"
          assert_select "input[name=?][disabled]", "user[email]"
          assert_select "select[name=?]", "user[employee_type]", count: 0
        end
      end

      it "renders Advanced user links" do
        render template: subject, layout: "layouts/application"

        selector = "a[href=\"#{user_path(@user)}\"][data-method='delete']"
        expect(rendered).not_to have_selector(:css, selector)
        expect(rendered)
          .to have_link(nil, href: edit_user_employee_type_path(@user))
        expect(rendered)
          .not_to have_link(nil, href: edit_user_registration_path)
      end
    end

    context "when editing themselves" do
      before { @user = assign(:user, current_user) }

      it "renders the edit user form" do
        render

        assert_select "form[action=?][method=?]", user_path(@user), "post" do
          assert_select "input[name=?]", "user[name]"
          assert_select "input[name=?][disabled]", "user[email]"
          assert_select "select[name=?]", "user[employee_type]", count: 0
        end
      end

      it "renders Advanced user links" do
        render template: subject, layout: "layouts/application"

        selector = "a[href=\"#{user_path(@user)}\"][data-method='delete']"
        expect(rendered).not_to have_selector(:css, selector)
        expect(rendered).to have_link(nil, href: edit_user_registration_path)
        expect(rendered)
          .not_to have_link(nil, href: edit_user_employee_type_path(@user))
        expect(rendered)
          .not_to have_link(nil, href: new_user_employee_type_path(@user))
      end

      context "when they have a valid GithubAccount" do
        before { @user.update github_id: 3562, github_username: "foo" }

        let(:github_account) { @user.github_account }

        it "renders their GithubAccount" do
          render
          expect(rendered).to have_link(nil, href: github_account.remote_url)
          selector = "a[href=\"#{github_account_url}\"][data-method='delete']"
          expect(rendered).to have_selector(:css, selector)
        end

        it "doesn't render new connection link" do
          render
          expect(rendered)
            .not_to have_link(nil, href: user_github_omniauth_authorize_path)
        end
      end

      context "when they don't have a valid GithubAccount" do
        before { @user.update github_id: nil }

        let(:github_account) { @user.github_account }

        it "renders new connection link" do
          render
          expect(rendered)
            .to have_link(nil, href: user_github_omniauth_authorize_path)
        end
      end
    end

    context "when editing a non-employee" do
      let(:user) { Fabricate(:user_unemployed) }

      before { @user = assign(:user, user) }

      it "renders the edit user form" do
        render

        assert_select "form[action=?][method=?]", user_path(@user), "post" do
          assert_select "input[name=?]", "user[name]"
          assert_select "input[name=?][disabled]", "user[email]"
          assert_select "select[name=?]", "user[employee_type]", count: 0
        end
      end

      it "renders Advanced user links" do
        render template: subject, layout: "layouts/application"

        selector = "a[href=\"#{user_path(@user)}\"][data-method='delete']"
        expect(rendered).not_to have_selector(:css, selector)
        expect(rendered)
          .not_to have_link(nil, href: edit_user_employee_type_path(@user))
        expect(rendered)
          .to have_link(nil, href: new_user_employee_type_path(@user))
        expect(rendered)
          .not_to have_link(nil, href: edit_user_registration_path)
      end

      it "doesn't render new connection link" do
        render
        expect(rendered)
          .not_to have_link(nil, href: user_github_omniauth_authorize_path)
      end
    end

    context "when editing a user with valid GithubAccount" do
      let(:user) do
        Fabricate(:user_reviewer, github_id: 4522, github_username: "username")
      end
      let(:github_account) { user.github_account }

      before { @user = assign(:user, user) }

      it "renders their GithubAccount" do
        render
        expect(rendered).to have_link(nil, href: github_account.remote_url)
        selector = "a[href=\"#{github_account_url}\"][data-method='delete']"
        expect(rendered).not_to have_selector(:css, selector)
      end
    end
  end

  %w[reviewer worker reporter].each do |employee_type|
    context "for a #{employee_type}" do
      let(:current_user) { Fabricate("user_#{employee_type}") }

      before { enable_can(view, current_user) }

      before do
        @user = assign(:user, current_user)
      end

      it "renders the edit user form" do
        render

        assert_select "form[action=?][method=?]", user_path(@user), "post" do
          assert_select "input[name=?]", "user[name]"
          assert_select "input[name=?][disabled]", "user[email]"
          assert_select "select[name=?]", "user[employee_type]", count: 0
        end
      end

      it "renders Advanced user link" do
        render template: subject, layout: "layouts/application"

        selector = "a[href=\"#{user_path(@user)}\"][data-method='delete']"
        expect(rendered).not_to have_selector(:css, selector)
        expect(rendered).to have_link(nil, href: edit_user_registration_path)
        expect(rendered)
          .not_to have_link(nil, href: edit_user_employee_type_path(@user))
        expect(rendered)
          .not_to have_link(nil, href: new_user_employee_type_path(@user))
      end

      context "when they have a valid GithubAccount" do
        before { @user.update github_id: 3562, github_username: "foo" }

        let(:github_account) { @user.github_account }

        it "renders their GithubAccount" do
          render
          expect(rendered).to have_link(nil, href: github_account.remote_url)
          selector = "a[href=\"#{github_account_url}\"][data-method='delete']"
          expect(rendered).to have_selector(:css, selector)
        end

        it "doesn't render new connection link" do
          render
          expect(rendered)
            .not_to have_link(nil, href: user_github_omniauth_authorize_path)
        end
      end

      context "when they don't have a valid GithubAccount" do
        before { @user.update github_id: nil }

        let(:github_account) { @user.github_account }

        it "renders new connection link" do
          render
          expect(rendered)
            .to have_link(nil, href: user_github_omniauth_authorize_path)
        end
      end
    end
  end
end
