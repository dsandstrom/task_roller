# frozen_string_literal: true

require "rails_helper"

RSpec.describe "resolutions/edit", type: :view do
  let(:project) { Fabricate(:project) }

  context "for an admin" do
    let(:current_user) { Fabricate(:user_admin) }

    before(:each) do
      enable_can(view, current_user)
      @issue = assign(:issue, Fabricate(:issue, project: project))
      @resolution = assign(:resolution, Fabricate(:resolution, issue: @issue))
    end

    let(:url) { issue_resolution_url(@issue, @resolution) }

    it "renders new resolution form" do
      render

      assert_select "form[action=?][method=?]", url, "post" do
        assert_select "select[name=?]", "resolution[user_id]"
      end
    end
  end
end
