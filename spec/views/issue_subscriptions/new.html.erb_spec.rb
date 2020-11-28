# frozen_string_literal: true

require "rails_helper"

RSpec.describe "issue_subscriptions/new", type: :view do
  before(:each) do
    @issue = assign(:issue, Fabricate(:issue))
    assign(:issue_subscription, IssueSubscription.new)
  end

  context "for a reporter" do
    let(:current_user) { Fabricate(:user_reporter) }

    before { enable_can(view, current_user) }

    it "renders new issue_subscription form" do
      render

      url = issue_issue_subscriptions_path(@issue)
      assert_select "form[action=?][method=?]", url, "post"
    end
  end
end
