# frozen_string_literal: true

require "rails_helper"

RSpec.describe "category_issues_subscriptions/new", type: :view do
  before(:each) do
    @category = assign(:category, Fabricate(:category))
    assign(:category_issues_subscription,
           Fabricate.build(:category_issues_subscription))
  end

  it "renders new category_issues_subscription form" do
    render

    url = category_issues_subscriptions_path(@category)
    assert_select "form[action=?][method=?]", url, "post"
  end
end
