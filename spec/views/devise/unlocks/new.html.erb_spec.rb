# frozen_string_literal: true

require "rails_helper"

RSpec.describe "devise/unlocks/new", type: :view do
  let(:url) { user_unlock_path }

  before do
    enable_devise_user(view)
  end

  context "when allowing registration" do
    before { allow(User).to receive(:allow_registration?) { true } }

    it "renders new session form" do
      render

      assert_select "form[action=?][method=?]", url, "post" do
        assert_select "input[name=?]", "user[email]"
      end
    end

    it "renders links" do
      render template: "devise/unlocks/new", layout: "layouts/application"

      expect(rendered).to have_link(nil, href: new_user_session_path)
      expect(rendered).to have_link(nil, href: new_user_password_path)
      expect(rendered).to have_link(nil, href: new_user_confirmation_path)
      expect(rendered).to have_link(nil, href: new_user_registration_path)
      expect(rendered)
        .to have_link(nil, href: user_github_omniauth_authorize_path)
    end
  end

  context "when disallowing registration" do
    before { allow(User).to receive(:allow_registration?) { false } }

    it "renders new session form" do
      render

      assert_select "form[action=?][method=?]", url, "post" do
        assert_select "input[name=?]", "user[email]"
      end
    end

    it "rendrs links" do
      render template: "devise/unlocks/new", layout: "layouts/application"

      expect(rendered).to have_link(nil, href: new_user_session_path)
      expect(rendered).to have_link(nil, href: new_user_password_path)
      expect(rendered).to have_link(nil, href: new_user_confirmation_path)
      expect(rendered).not_to have_link(nil, href: new_user_registration_path)
      expect(rendered)
        .not_to have_link(nil, href: user_github_omniauth_authorize_path)
    end
  end
end
