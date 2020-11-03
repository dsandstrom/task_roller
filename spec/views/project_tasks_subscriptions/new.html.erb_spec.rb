# frozen_string_literal: true

require "rails_helper"

RSpec.describe "project_tasks_subscriptions/new", type: :view do
  before(:each) do
    @project = assign(:project, Fabricate(:project))
    assign(:project_tasks_subscription,
           Fabricate.build(:project_tasks_subscription))
  end

  it "renders new project_tasks_subscription form" do
    render

    url = project_tasks_subscriptions_path(@project)
    assert_select "form[action=?][method=?]", url, "post" do
    end
  end
end
