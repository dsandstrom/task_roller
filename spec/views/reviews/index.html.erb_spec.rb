# frozen_string_literal: true

require "rails_helper"

RSpec.describe "reviews/index", type: :view do
  context "for an admin" do
    let(:admin) { Fabricate(:user_admin) }

    before { enable_can(view, admin) }

    context "when task has reviews" do
      let(:task) { assign(:task, Fabricate(:task)) }
      let(:first_review) { Fabricate(:disapproved_review, task: task) }
      let(:second_review) { Fabricate(:pending_review, task: task) }

      before do
        assign(:reviews, [first_review, second_review])
      end

      it "renders a list of reviews" do
        render
        [first_review, second_review].each do |review|
          assert_select "#review_#{review.id}"
        end
      end
    end
  end

  %w[reviewer worker reporter].each do |employee_type|
    context "for a #{employee_type}" do
      let(:current_user) { Fabricate("user_#{employee_type}") }

      before { enable_can(view, current_user) }

      context "when task has reviews" do
        let(:task) { assign(:task, Fabricate(:task)) }
        let(:first_review) { Fabricate(:disapproved_review, task: task) }
        let(:second_review) { Fabricate(:pending_review, task: task) }

        before do
          assign(:reviews, [first_review, second_review])
        end

        it "renders a list of reviews" do
          render
          [first_review, second_review].each do |review|
            assert_select "#review_#{review.id}"
          end
        end
      end
    end
  end
end
