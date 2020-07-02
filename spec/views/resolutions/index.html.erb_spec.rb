# frozen_string_literal: true

require "rails_helper"

RSpec.describe "resolutions/index", type: :view do
  context "when issue has resolutions" do
    let(:issue) { assign(:issue, Fabricate(:issue)) }
    let(:first_resolution) { Fabricate(:disapproved_resolution, issue: issue) }
    let(:second_resolution) { Fabricate(:pending_resolution, issue: issue) }

    before do
      assign(:resolutions, [first_resolution, second_resolution])
    end

    it "renders a list of resolutions" do
      render
      assert_select "#resolution_#{first_resolution.id}"
      assert_select "#resolution_#{second_resolution.id}"
    end
  end
end
