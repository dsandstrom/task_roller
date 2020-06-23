# frozen_string_literal: true

require "rails_helper"

RSpec.describe "reviews/new", type: :view do
  let(:task) { assign(:task, Fabricate(:task)) }
  let(:url) { task_reviews_url(task) }

  before do
    assign(:review, task.reviews.build)
  end

  it "renders new review form" do
    render

    assert_select "form[action=?][method=?]", url, "post" do
      assert_select "select[name=?]", "review[user_id]"
      assert_select "input[name=?]", "review[approved]"
    end
  end
end
