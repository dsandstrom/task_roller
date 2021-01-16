# frozen_string_literal: true

require "rails_helper"

RSpec.describe "users/show", type: :view do
  let(:subject) { "users/show" }
  let(:user_reporter) { Fabricate(:user_reporter) }

  context "for an admin" do
    let(:current_user) { Fabricate(:user_admin) }

    before do
      enable_can(view, current_user)
      @user = assign(:user, user_reporter)
    end

    it "renders attributes in #user-detail-{@user.id}" do
      render template: subject, layout: "layouts/application"
      expect(rendered).to match(/id="user-detail-#{@user.id}"/)
      expect(rendered).to have_link(nil, href: edit_user_path(@user))
    end
  end

  %w[reviewer worker reporter].each do |employee_type|
    context "for a #{employee_type}" do
      let(:current_user) { Fabricate("user_#{employee_type}") }

      before { enable_can(view, current_user) }

      context "when someone else" do
        before do
          @user = assign(:user, user_reporter)
        end

        it "renders attributes in #user-detail-{@user.id}" do
          render template: subject, layout: "layouts/application"
          expect(rendered).to match(/id="user-detail-#{@user.id}"/)
          expect(rendered).not_to have_link(nil, href: edit_user_path(@user))
        end
      end

      context "when them" do
        before do
          @user = assign(:user, current_user)
        end

        it "renders attributes in #user-detail-{@user.id}" do
          render template: subject, layout: "layouts/application"
          expect(rendered).to match(/id="user-detail-#{@user.id}"/)
          expect(rendered).to have_link(nil, href: edit_user_path(@user))
        end
      end
    end
  end
end
