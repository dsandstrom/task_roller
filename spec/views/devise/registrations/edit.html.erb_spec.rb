# frozen_string_literal: true

require "rails_helper"

RSpec.describe "devise/registrations/edit", type: :view do
  let(:url) { user_registration_path }

  before { enable_devise_user(view) }

  context "for a admin" do
    let(:user) { Fabricate(:user_admin) }

    before do
      @user = assign(:user, user)
      enable_can(view, @user)
    end

    it "renders edit registration form" do
      render

      assert_select "form[action=?][method=?]", url, "post" do
        assert_select "input[name=?]", "user[email]", count: 0
        assert_select "input[name=?]", "user[name]", count: 0
        assert_select "input[name=?]", "user[password]"
        assert_select "input[name=?]", "user[password_confirmation]"
      end
    end

    it "doesn't render cancel form" do
      render
      cancel_url = user_employee_type_path(@user)
      assert_select "form[action=?]", cancel_url, count: 0
    end
  end

  %w[reviewer worker reporter].each do |employee_type|
    context "for a #{employee_type}" do
      let(:user) { Fabricate("user_#{employee_type}") }

      before do
        @user = assign(:user, user)
        enable_can(view, @user)
      end

      it "renders edit registration form" do
        render

        assert_select "form[action=?][method=?]", url, "post" do
          assert_select "input[name=?]", "user[email]", count: 0
          assert_select "input[name=?]", "user[name]", count: 0
          assert_select "input[name=?]", "user[password]"
          assert_select "input[name=?]", "user[password_confirmation]"
        end
      end

      it "renders cancel form" do
        render
        cancel_url = user_employee_type_path(@user)
        assert_select "form[action=?]", cancel_url do
          assert_select "input[name=?][value=?]", "_method", "delete"
        end
      end
    end
  end
end
