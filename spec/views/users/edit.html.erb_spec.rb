# frozen_string_literal: true

require "rails_helper"

RSpec.describe "users/edit", type: :view do
  context "for a reporter" do
    let(:current_user) { Fabricate(:user_reporter) }

    before do
      enable_can(view, current_user)
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
  end
end
