# frozen_string_literal: true

require "rails_helper"

RSpec.describe "devise/passwords/edit", type: :view do
  let(:current_user) { Fabricate(:user_reporter) }
  let(:url) { user_password_path }

  before do
    enable_can(view, current_user)
    enable_devise_user(view)
  end

  context "for a guest" do
    it "renders edit password form" do
      render

      assert_select "form[action=?][method=?]", url, "post" do
        assert_select "input[name=?]", "user[password]"
        assert_select "input[name=?]", "user[password_confirmation]"
      end
    end

    it "renders links" do
      render

      expect(rendered).to have_link(nil, href: new_user_session_path)
      expect(rendered).to have_link(nil, href: new_user_confirmation_path)
      expect(rendered).to have_link(nil, href: new_user_unlock_path)
    end
  end
end
