# frozen_string_literal: true

require "rails_helper"

RSpec.describe "category_issue_subscriptions/new", type: :view do
  before(:each) do
    @category = assign(:category, Fabricate(:category))
    assign(:category_issue_subscription,
           Fabricate.build(:category_issue_subscription))
  end

  it "renders new category_issue_subscription form" do
    render

    url = category_issue_subscriptions_path(@category)
    assert_select "form[action=?][method=?]", url, "post" do
    end
  end
end
