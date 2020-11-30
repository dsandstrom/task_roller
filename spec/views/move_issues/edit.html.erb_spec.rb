# frozen_string_literal: true

require "rails_helper"

RSpec.describe "move_issues/edit", type: :view do
  before(:each) do
    @issue = assign(:issue, Fabricate(:issue))
  end

  context "for a reviewer" do
    let(:current_user) { Fabricate(:user_reviewer) }

    before { enable_can(view, current_user) }

    it "renders move_issue form" do
      render

      url = move_issue_path(@issue)
      assert_select "form[action=?]", url do
        assert_select "select[name=?]", "issue[project_id]"
      end
    end
  end
end
