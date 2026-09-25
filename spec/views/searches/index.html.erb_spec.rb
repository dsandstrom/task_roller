require "rails_helper"

RSpec.describe "searches/index", type: :view do
  context "for a reviewer" do
    let(:current_user) { Fabricate(:user_reviewer) }
    let(:issue) { Fabricate(:issue) }
    let(:task) { Fabricate(:task) }

    before { enable_can(view, current_user) }

    context "when search_results" do
      context "for issues and tasks" do
        before do
          issue
          task
          assign(:search_results, page(SearchResult.all))
        end

        it "renders issues" do
          render

          assert_select ".issues #issue-#{issue.id}"
        end

        it "renders tasks" do
          render

          assert_select ".tasks #task-#{task.id}"
        end

        it "renders filter form" do
          render

          assert_select "form[action=?][method=?]", search_results_path,
                        "get" do
            assert_select "input[name=?]", "query"
            assert_select "input[name=?]", "order"
            assert_select "input[name=?]", "type"
          end
        end

        context "when search subscription doesn't exist" do
          let(:search_subscription) do
            Fabricate.build(:search_subscription, user: current_user,
                                                  include_issues: true,
                                                  include_tasks: true,
                                                  term: "term")
          end

          before do
            assign(:search_subscription, search_subscription)
          end

          it "renders new SearchSubscription form" do
            render

            assert_select "form[action=?][method=?]", search_subscriptions_path,
                          "post"
          end

          it "renders link to all search_subscriptions" do
            render

            expect(rendered).to have_link(nil, href: search_subscriptions_path)
          end
        end

        context "when search subscription exists" do
          let(:search_subscription) do
            Fabricate(:search_subscription, user: current_user,
                                            include_issues: true,
                                            include_tasks: true,
                                            term: "term")
          end

          before do
            assign(:search_subscription, search_subscription)
          end

          it "doesn't render new SearchSubscription form" do
            render

            assert_select "form[action=?][method=?]",
                          search_subscriptions_path, "post", count: 0
          end

          it "renders search subscription unsubscribe form" do
            render

            assert_select "form[action=?][method=?]",
                          toggle_search_subscription_path(search_subscription),
                          "post"
          end
        end
      end

      context "for just issues" do
        before do
          issue
          assign(:search_results, page(Issue.all))
        end

        it "renders issues" do
          render

          assert_select ".issues #issue-#{issue.id}"
        end
      end

      context "for just tasks" do
        before do
          task
          assign(:search_results, page(Task.all))
        end

        it "renders issues" do
          render

          assert_select ".tasks #task-#{task.id}"
        end
      end
    end

    context "when no search_results" do
      before { assign(:search_results, page(SearchResult.all)) }

      it "doesn't render issues and tasks" do
        render

        assert_select ".issues", count: 0
        assert_select ".tasks", count: 0
      end
    end
  end
end
