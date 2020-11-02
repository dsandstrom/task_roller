# frozen_string_literal: true

require "rails_helper"

RSpec.describe "project_task_subscriptions/new", type: :view do
  before(:each) do
    @project = assign(:project, Fabricate(:project))
    assign(:project_task_subscription,
           Fabricate.build(:project_task_subscription))
  end

  it "renders new project_task_subscription form" do
    render

    url = project_task_subscriptions_path(@project)
    assert_select "form[action=?][method=?]", url, "post" do
    end
  end
end
