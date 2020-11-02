# frozen_string_literal: true

require "rails_helper"

RSpec.describe "project_issue_subscriptions/new", type: :view do
  before(:each) do
    @project = assign(:project, Fabricate(:project))
    assign(:project_issue_subscription,
           Fabricate.build(:project_issue_subscription))
  end

  it "renders new project_issue_subscription form" do
    render

    url = project_issue_subscriptions_path(@project)
    assert_select "form[action=?][method=?]", url, "post" do
    end
  end
end
