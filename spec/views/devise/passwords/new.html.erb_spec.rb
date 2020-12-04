# frozen_string_literal: true

require "rails_helper"

RSpec.describe "devise/passwords/new", type: :view do
  let(:url) { user_password_path }

  before { enable_devise_user(view) }

  it "renders new session form" do
    render

    assert_select "form[action=?][method=?]", url, "post" do
      assert_select "input[name=?]", "user[email]"
    end
  end

  it "renders links" do
    render template: subject, layout: "layouts/application"

    expect(rendered).to have_link(nil, href: new_user_session_path)
    expect(rendered).to have_link(nil, href: new_user_confirmation_path)
    expect(rendered).to have_link(nil, href: new_user_unlock_path)
  end
end
