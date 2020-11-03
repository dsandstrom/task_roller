# frozen_string_literal: true

require "rails_helper"

RSpec.describe "category_tasks_subscriptions/new", type: :view do
  before(:each) do
    @category = assign(:category, Fabricate(:category))
    assign(:category_tasks_subscription,
           Fabricate.build(:category_tasks_subscription))
  end

  it "renders new category_tasks_subscription form" do
    render

    url = category_tasks_subscriptions_path(@category)
    assert_select "form[action=?][method=?]", url, "post" do
    end
  end
end
