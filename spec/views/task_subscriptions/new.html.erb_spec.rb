# frozen_string_literal: true

require "rails_helper"

RSpec.describe "task_subscriptions/new", type: :view do
  before(:each) do
    @task = assign(:task, Fabricate(:task))
    assign(:task_subscription, TaskSubscription.new)
  end

  context "for a reporter" do
    let(:current_user) { Fabricate(:user_reporter) }

    before { enable_can(view, current_user) }

    it "renders new task_subscription form" do
      render

      url = task_task_subscriptions_path(@task)
      assert_select "form[action=?][method=?]", url, "post"
    end
  end
end
