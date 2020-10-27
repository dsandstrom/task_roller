# frozen_string_literal: true

require "rails_helper"

RSpec.describe "issue_subscriptions/index", type: :view do
  %w[worker reporter].each do |employee_type|
    let(:first_issue) { Fabricate(:issue) }
    let(:second_issue) { Fabricate(:issue) }

    before(:each) do
      assign(:issues, page([first_issue, second_issue]))
    end

    context "for a #{employee_type}" do
      let(:current_user) { Fabricate("user_#{employee_type}") }

      before { enable_pundit(view, current_user) }

      it "renders a list of subscribed issues" do
        render

        assert_select "#issue-#{first_issue.id}"
        assert_select "#issue-#{second_issue.id}"
      end
    end
  end
end
