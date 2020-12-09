# frozen_string_literal: true

require "rails_helper"

RSpec.describe "cancel_users/edit", type: :view do
  let(:reporter) { Fabricate(:user_reporter) }

  context "for an admin" do
    let(:current_user) { Fabricate(:user_admin) }

    before { enable_can(view, current_user) }

    context "when editing a reporter" do
      before { @user = assign(:user, reporter) }

      it "renders the edit user form" do
        render

        assert_select "form[action=?]", cancel_user_path(@user)
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

        assert_select "form[action=?]", cancel_user_path(@user)
      end
    end
  end
end
