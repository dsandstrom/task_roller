# frozen_string_literal: true

require "rails_helper"

RSpec.describe "promote_users/edit", type: :view do
  let(:reporter) { Fabricate(:user_reporter) }

  context "for an admin" do
    let(:current_user) { Fabricate(:user_admin) }

    before { enable_can(view, current_user) }

    context "when editing a reporter" do
      before { @user = assign(:user, reporter) }

      it "renders the edit user form" do
        render

        assert_select "form[action=?]", promote_user_path(@user) do
          assert_select "select[name=?]", "user[employee_type]"
        end
      end
    end
  end
end
