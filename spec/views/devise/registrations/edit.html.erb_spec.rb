# frozen_string_literal: true

require "rails_helper"

RSpec.describe "devise/registrations/edit", type: :view do
  let(:url) { user_registration_path }

  before { enable_devise_user(view) }

  context "for a reporter" do
    let(:user) { Fabricate(:user_reporter) }

    before do
      @user = assign(:user, user)
      enable_can(view, user)
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
  end
end
