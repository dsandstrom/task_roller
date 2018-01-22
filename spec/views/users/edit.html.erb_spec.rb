# frozen_string_literal: true

require "rails_helper"

RSpec.describe "users/edit", type: :view do
  let(:user) { Fabricate(:user) }

  before(:each) { @user = assign(:user, user) }

  it "renders the edit user form" do
    render

    assert_select "form[action=?][method=?]", user_path(@user), "post" do
      assert_select "input[name=?]", "user[name]"
      assert_select "input[name=?]", "user[email]", count: 0
      assert_select "input[name=?]", "user[employee_type]", count: 0
    end
  end
end
