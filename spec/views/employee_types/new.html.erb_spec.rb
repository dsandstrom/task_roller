# frozen_string_literal: true

require "rails_helper"

RSpec.describe "employee_types/new", type: :view do
  context "for an admin" do
    let(:current_user) { Fabricate(:user_admin) }

    before { enable_can(view, current_user) }

    context "when requested user is a non-employee" do
      let(:unemployed) { Fabricate(:user_unemployed) }

      before { @user = assign(:user, unemployed) }

      it "renders the new user employee_type form" do
        render

        assert_select "form[action=?]", user_employee_types_path(@user) do
          assert_select "select[name=?]", "user[employee_type]"
        end
      end

      it "doesn't render cancel form" do
        render
        url = user_employee_type_path(@user)
        assert_select "form[action=?]", url, count: 0
      end
    end
  end
end
