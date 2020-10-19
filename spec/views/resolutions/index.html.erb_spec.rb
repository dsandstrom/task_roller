# frozen_string_literal: true

require "rails_helper"

RSpec.describe "resolutions/index", type: :view do
  context "for an admin" do
    let(:admin) { Fabricate(:user_admin) }

    before { enable_pundit(view, admin) }

    context "when issue has resolutions" do
      let(:issue) { assign(:issue, Fabricate(:issue)) }
      let(:first_resolution) do
        Fabricate(:disapproved_resolution, issue: issue)
      end
      let(:second_resolution) { Fabricate(:pending_resolution, issue: issue) }

      before do
        assign(:resolutions, [first_resolution, second_resolution])
      end

      it "renders a list of resolutions" do
        render
        assert_select "#resolution_#{first_resolution.id}"
        assert_select "#resolution_#{second_resolution.id}"
      end

      it "renders destroy links" do
        render
        [first_resolution, second_resolution].each do |resolution|
          url = issue_resolution_path(issue, resolution)
          assert_select "a[data-method='delete'][href=\"#{url}\"]"
        end
      end
    end
  end

  %w[reviewer worker reporter].each do |employee_type|
    context "for a #{employee_type}" do
      let(:current_user) { Fabricate("user_#{employee_type}") }

      before { enable_pundit(view, current_user) }

      context "when issue has resolutions" do
        let(:issue) { assign(:issue, Fabricate(:issue)) }
        let(:first_resolution) do
          Fabricate(:disapproved_resolution, issue: issue)
        end
        let(:second_resolution) { Fabricate(:pending_resolution, issue: issue) }

        before do
          assign(:resolutions, [first_resolution, second_resolution])
        end

        it "renders a list of resolutions" do
          render
          assert_select "#resolution_#{first_resolution.id}"
          assert_select "#resolution_#{second_resolution.id}"
        end

        it "doesn't render destroy links" do
          render
          [first_resolution, second_resolution].each do |resolution|
            url = issue_resolution_path(issue, resolution)
            assert_select "a[data-method='delete'][href=\"#{url}\"]", count: 0
          end
        end
      end
    end
  end
end
