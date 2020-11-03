# frozen_string_literal: true

require "rails_helper"

RSpec.describe "categories/index", type: :view do
  let(:first_category) { Fabricate(:category) }
  let(:second_category) { Fabricate(:category) }

  before(:each) { assign(:categories, [first_category, second_category]) }

  context "for an admin" do
    let(:admin) { Fabricate(:user_admin) }

    before { enable_can(view, admin) }

    it "renders a list of categories" do
      render

      assert_select "#category-#{first_category.id} .category-name",
                    text: first_category.name
      expect(rendered)
        .to have_link(nil, href: edit_category_path(first_category))
      assert_select "#category-#{first_category.id} a[data-method=\"delete\"]"

      assert_select "#category-#{second_category.id} .category-name",
                    text: second_category.name
      expect(rendered)
        .to have_link(nil, href: edit_category_path(second_category))
      assert_select "#category-#{second_category.id} a[data-method=\"delete\"]"
    end

    it "renders new category link" do
      render

      expect(rendered).to have_link(nil, href: new_category_path)
    end
  end

  context "for a reviewer" do
    let(:reviewer) { Fabricate(:user_reviewer) }

    before { enable_can(view, reviewer) }

    it "renders a list of categories" do
      render

      [first_category, second_category].each do |category|
        assert_select "#category-#{category.id} .category-name",
                      text: category.name
        expect(rendered).to have_link(nil, href: edit_category_path(category))
        assert_select "#category-#{category.id} a[data-method=\"delete\"]",
                      count: 0
      end
    end

    it "render new category link" do
      render

      expect(rendered).to have_link(nil, href: new_category_path)
    end

    context "when subscribed to issues and tasks" do
      let(:issue_subscription) do
        Fabricate(:category_issues_subscription, category: first_category,
                                                 user: reviewer)
      end

      let(:task_subscription) do
        Fabricate(:category_tasks_subscription, category: second_category,
                                                user: reviewer)
      end

      it "renders subscribe and unsubscribe buttons" do
        first_unsubscribe =
          category_issues_subscription_path(first_category, issue_subscription)
        second_unsubscribe =
          category_tasks_subscription_path(second_category, task_subscription)

        first_issue_subscribe =
          category_issues_subscriptions_path(first_category)
        second_issue_subscribe =
          category_issues_subscriptions_path(second_category)
        first_task_subscribe =
          category_tasks_subscriptions_path(first_category)
        second_task_subscribe =
          category_tasks_subscriptions_path(second_category)

        render

        expect(rendered).to have_link(nil, href: first_unsubscribe)
        expect(rendered).to have_link(nil, href: second_unsubscribe)
        expect(rendered).not_to have_link(nil, href: first_issue_subscribe)
        expect(rendered).to have_link(nil, href: second_issue_subscribe)
        expect(rendered).to have_link(nil, href: first_task_subscribe)
        expect(rendered).not_to have_link(nil, href: second_task_subscribe)
      end
    end
  end

  %w[worker reporter].each do |employee_type|
    context "for a #{employee_type}" do
      let(:current_user) { Fabricate("user_#{employee_type}") }

      before { enable_can(view, current_user) }

      it "renders a list of categories" do
        render

        [first_category, second_category].each do |category|
          assert_select "#category-#{category.id} .category-name",
                        text: category.name
          assert_select "#category-#{category.id} .category-name",
                        text: category.name

          expect(rendered)
            .not_to have_link(nil, href: edit_category_path(category))
          assert_select "#category-#{category.id} a[data-method=\"delete\"]",
                        count: 0
        end
      end

      it "doesn't render a new category link" do
        render

        expect(rendered).not_to have_link(nil, href: new_category_path)
      end
    end
  end
end
