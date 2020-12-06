# frozen_string_literal: true

require "rails_helper"

RSpec.describe "devise/registrations/new", type: :view do
  let(:user) { Fabricate(:user_reporter) }
  let(:url) { user_registration_path }

  before do
    enable_can(view, user)
    enable_devise_user(view)
  end

  it "renders new registrations form" do
    render

    assert_select "form[action=?][method=?]", url, "post" do
      assert_select "input[name=?]", "user[email]"
      assert_select "input[name=?]", "user[name]"
      assert_select "input[name=?]", "user[password]"
      assert_select "input[name=?]", "user[password_confirmation]"
    end
  end

  it "renders links" do
    render template: subject, layout: "layouts/application"

    expect(rendered).to have_link(nil, href: new_user_session_path)
    expect(rendered).to have_link(nil, href: new_user_confirmation_path)
    expect(rendered).to have_link(nil, href: new_user_unlock_path)
  end
end
