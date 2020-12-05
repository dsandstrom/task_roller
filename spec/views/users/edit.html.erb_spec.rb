# frozen_string_literal: true

require "rails_helper"

RSpec.describe "users/edit", type: :view do
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
          assert_select "input[name=?]", "user[employee_type]", count: 0
        end
      end

      it "renders Advanced user links" do
        render
        selector = "a[href=\"#{user_path(@user)}\"][data-method='delete']"
        expect(rendered).to have_selector(:css, selector)
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
          assert_select "input[name=?]", "user[employee_type]", count: 0
        end
      end

      it "renders Advanced user links" do
        render
        selector = "a[href=\"#{user_path(@user)}\"][data-method='delete']"
        expect(rendered).not_to have_selector(:css, selector)
        expect(rendered).to have_link(nil, href: edit_user_registration_path)
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
          assert_select "input[name=?]", "user[employee_type]", count: 0
        end
      end

      it "renders Advanced user link" do
        render
        selector = "a[href=\"#{user_path(@user)}\"][data-method='delete']"
        expect(rendered).not_to have_selector(:css, selector)
        expect(rendered).to have_link(nil, href: edit_user_registration_path)
      end
    end
  end
end
