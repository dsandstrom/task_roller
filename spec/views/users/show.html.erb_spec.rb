# frozen_string_literal: true

require "rails_helper"

RSpec.describe "users/show", type: :view do
  let(:user_reporter) { Fabricate(:user_reporter) }

  before(:each) do
    @user = assign(:user, user_reporter)
  end

  context "for an admin" do
    let(:current_user) { Fabricate(:user_admin) }

    before { enable_pundit(view, current_user) }

    it "renders attributes in #user-detail-{@user.id}" do
      render
      expect(rendered).to match(/id="user-detail-#{@user.id}"/)
      expect(rendered).to have_link(nil, href: edit_user_path(@user))
      selector = "a[href=\"#{user_path(@user)}\"][data-method='delete']"
      expect(rendered).to have_selector(:css, selector)
    end
  end

  %w[reviewer worker reporter].each do |employee_type|
    context "for a #{employee_type}" do
      let(:current_user) { Fabricate("user_#{employee_type}") }

      before { enable_pundit(view, current_user) }

      it "renders attributes in #user-detail-{@user.id}" do
        render
        expect(rendered).to match(/id="user-detail-#{@user.id}"/)
        expect(rendered).not_to have_link(nil, href: edit_user_path(@user))
        expect(rendered).not_to have_link(nil, href: user_path(@user))
      end
    end
  end
end
