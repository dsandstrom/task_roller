# frozen_string_literal: true

require "rails_helper"

RSpec.describe "reviews/new", type: :view do
  let(:task) { assign(:task, Fabricate(:task)) }
  let(:url) { task_reviews_url(task) }

  context "for a reviewer" do
    let(:current_user) { Fabricate(:user_reviewer) }

    before do
      enable_can(view, current_user)
      assign(:review, task.reviews.build)
    end

    it "renders new review form" do
      render

      assert_select "form[action=?][method=?]", url, "post" do
        assert_select "select[name=?]", "review[user_id]"
      end
    end
  end
end
