require "rails_helper"

RSpec.describe "issues/pending", type: :view do
  %w[reviewer admin].each do |employee_type|
    context "for a #{employee_type}" do
      let(:current_user) { Fabricate("user_#{employee_type}") }
      let(:issue) { Fabricate(:pending_issue) }

      before do
        enable_can(view, current_user)
        assign(:issues, page([issue]))
      end

      it "renders a list of issues" do
        render
        assert_select "#issue-#{issue.id}"
      end
    end
  end
end
