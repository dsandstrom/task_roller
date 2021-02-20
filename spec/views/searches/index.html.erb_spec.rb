# frozen_string_literal: true

require "rails_helper"

RSpec.describe "searches/index", type: :view do
  context "for a reviewer" do
    let(:current_user) { Fabricate(:user_reviewer) }
    let(:issue) { Fabricate(:issue) }
    let(:task) { Fabricate(:task) }

    before { enable_can(view, current_user) }

    context "when search_results" do
      before { assign(:search_results, page([issue, task])) }

      it "renders issues" do
        render

        assert_select ".issues #issue-#{issue.id}"
      end

      it "renders tasks" do
        render

        assert_select ".tasks #task-#{task.id}"
      end
    end

    context "when no search_results" do
      before { assign(:search_results, page([])) }

      it "doesn't render issues and tasks" do
        render

        assert_select ".issues", count: 0
        assert_select ".tasks", count: 0
      end
    end
  end
end
