# frozen_string_literal: true

require "rails_helper"

RSpec.describe "reviews/edit", type: :view do
  let(:project) { Fabricate(:project) }

  context "for an admin" do
    let(:current_user) { Fabricate(:user_admin) }

    before(:each) do
      enable_can(view, current_user)
      @task = assign(:task, Fabricate(:task, project: project))
      @review = assign(:review, Fabricate(:review, task: @task))
    end

    let(:url) { task_review_url(@task, @review) }

    it "renders new review form" do
      render

      assert_select "form[action=?][method=?]", url, "post" do
        assert_select "select[name=?]", "review[user_id]"
      end
    end
  end
end
