# frozen_string_literal: true

require "rails_helper"

RSpec.describe "users/show", type: :view do
  let(:user_reporter) { Fabricate(:user_reporter) }

  before(:each) { @user = assign(:user, user_reporter) }

  it "renders attributes in #user-detail-{@user.id}" do
    render
    expect(rendered).to match(/id="user-detail-#{@user.id}"/)
  end
end
