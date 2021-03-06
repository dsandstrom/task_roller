# frozen_string_literal: true

require "rails_helper"

RSpec.describe "issue_connections/new", type: :view do
  let(:issue) { Fabricate(:issue) }
  let(:path) { issue_connections_path(issue) }

  context "for an admin" do
    let(:current_user) { Fabricate(:user_admin) }

    before(:each) do
      enable_can(view, current_user)
      assign(:issue_connection, IssueConnection.new(source: issue))
    end

    it "renders new issue_connection form" do
      render

      assert_select "form[action=?][method=?]", path, "post" do
        assert_select "select[name=?]", "issue_connection[target_id]"
      end
    end
  end
end
