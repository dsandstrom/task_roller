# frozen_string_literal: true

require "rails_helper"

RSpec.describe "task_subscriptions/new", type: :view do
  before(:each) do
    @task = assign(:task, Fabricate(:task))
    assign(:task_subscription, TaskSubscription.new)
  end

  it "renders new task_subscription form" do
    render

    url = task_task_subscriptions_path(@task)
    assert_select "form[action=?][method=?]", url, "post" do
    end
  end
end
