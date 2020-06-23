# frozen_string_literal: true

require "rails_helper"

RSpec.describe "reviews/index", type: :view do
  context "when task has reviews" do
    let(:task) { assign(:task, Fabricate(:task)) }
    let(:first_review) { Fabricate(:disapproved_review, task: task) }
    let(:second_review) { Fabricate(:pending_review, task: task) }

    before do
      assign(:reviews, [first_review, second_review])
    end

    it "renders a list of reviews" do
      render
      assert_select "#review_#{first_review.id}"
      assert_select "#review_#{second_review.id}"
    end
  end
end
