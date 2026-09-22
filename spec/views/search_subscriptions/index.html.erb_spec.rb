require "rails_helper"

RSpec.describe "search_subscriptions/index", type: :view do
  context "for a reviewer" do
    let(:user) { Fabricate(:user_reviewer) }

    let(:first_search_subscription) do
      Fabricate(:search_subscription, user: user)
    end

    let(:second_search_subscription) do
      Fabricate(:inactive_search_subscription, user: user)
    end

    before do
      enable_can(view, user)
    end

    context "when user has SearchSubscriptions" do
      before do
        assign(:search_subscriptions,
               [first_search_subscription, second_search_subscription])
      end

      it "renders a list of search_subscriptions" do
        render

        [first_search_subscription,
         second_search_subscription].each do |search_subscription|
          assert_select "#search-subscription-#{search_subscription.id}"
          expect(rendered).to have_link(
            nil,
            href: search_subscription_path(search_subscription)
          )
          assert_select "a[data-turbo-method=\"delete\"][href=?]",
                        search_subscription_path(search_subscription)
          assert_select "form[data-turbo-method=\"patch\"][action=?]",
                        toggle_search_subscription_path(search_subscription)
        end
      end
    end

    context "when user has no SearchSubscriptions" do
      before do
        assign(:search_subscriptions, [])
      end

      it "renders a list of search_subscriptions" do
        render

        assert_select "#no-search-subscriptions"
      end
    end
  end
end
