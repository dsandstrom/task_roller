require "rails_helper"

RSpec.describe "reviews/index", type: :view do
  %w[reviewer admin].each do |employee_type|
    context "for a #{employee_type}" do
      let(:current_user) { Fabricate("user_#{employee_type}") }

      before do
        enable_can(view, current_user)
        Fabricate(:approved_review)
      end

      context "when a review is ready" do
        let(:pending_review) { Fabricate(:pending_review) }

        before do
          assign(:user, current_user)
          assign(:tasks, page([pending_review.task]))
        end

        it "renders a list of reviews" do
          render
          assert_select "#task-#{pending_review.task.id}"
        end
      end

      context "when no reviews ready" do
        before do
          assign(:user, current_user)
          assign(:tasks, page([]))
        end

        it "renders a list of reviews" do
          render
          assert_select ".no-reviews"
        end
      end
    end
  end
end
