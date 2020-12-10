# frozen_string_literal: true

require "rails_helper"

RSpec.describe "employee_types/edit", type: :view do
  context "for an admin" do
    let(:current_user) { Fabricate(:user_admin) }

    before { enable_can(view, current_user) }

    context "when requested user is a reporter" do
      let(:reporter) { Fabricate(:user_reporter) }

      before { @user = assign(:user, reporter) }

      it "renders the edit user employee_type form" do
        render

        assert_select "form[action=?]", user_employee_type_path(@user) do
          assert_select "select[name=?]", "user[employee_type]"
        end
      end

      it "renders destroy user employee_type link" do
        render

        url = user_employee_type_path(@user)
        assert_select "form[action=?]", url do
          assert_select "input[name=?][value=?]", "_method", "delete"
        end
      end
    end
  end
end
