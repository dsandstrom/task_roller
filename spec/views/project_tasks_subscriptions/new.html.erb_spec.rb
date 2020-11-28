# frozen_string_literal: true

require "rails_helper"

RSpec.describe "project_tasks_subscriptions/new", type: :view do
  before(:each) do
    @project = assign(:project, Fabricate(:project))
    assign(:project_tasks_subscription,
           Fabricate.build(:project_tasks_subscription))
  end

  context "for a reporter" do
    let(:current_user) { Fabricate(:user_reporter) }

    before { enable_can(view, current_user) }

    it "renders new project_tasks_subscription form" do
      render

      url = project_tasks_subscriptions_path(@project)
      assert_select "form[action=?][method=?]", url, "post"
    end
  end
end
