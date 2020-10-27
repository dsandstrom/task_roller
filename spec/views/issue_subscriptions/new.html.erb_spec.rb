# frozen_string_literal: true

require "rails_helper"

RSpec.describe "issue_subscriptions/new", type: :view do
  before(:each) do
    @issue = assign(:issue, Fabricate(:issue))
    assign(:issue_subscription, IssueSubscription.new)
  end

  it "renders new issue_subscription form" do
    render

    url = issue_issue_subscriptions_path(@issue)
    assert_select "form[action=?][method=?]", url, "post" do
    end
  end
end
