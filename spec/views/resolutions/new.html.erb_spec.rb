# frozen_string_literal: true

require "rails_helper"

RSpec.describe "resolutions/new", type: :view do
  let(:issue) { assign(:issue, Fabricate(:issue)) }
  let(:url) { issue_resolutions_url(issue) }

  before do
    assign(:resolution, issue.resolutions.build)
  end

  it "renders new resolution form" do
    render

    assert_select "form[action=?][method=?]", url, "post" do
      assert_select "select[name=?]", "resolution[user_id]"
    end
  end
end
