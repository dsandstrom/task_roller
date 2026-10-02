require "rails_helper"

RSpec.describe "search_subscriptions/new", type: :view do
  let(:path) { search_subscriptions_path }
  let(:user) { Fabricate(:user) }

  before(:each) do
    assign(:search_subscription, user.search_subscriptions.build)
  end

  it "renders new search_subscription form" do
    render

    assert_select "form[action=?][method=?]", path, "post" do
      assert_select "input[type=hidden][name=?]",
                    "search_subscription[category_id]"
      assert_select "input[type=hidden][name=?]",
                    "search_subscription[project_id]"
      assert_select "input[type=hidden][name=?]",
                    "search_subscription[source_user_id]"
      assert_select "input[type=hidden][name=?]",
                    "search_subscription[term]"
      assert_select "input[type=hidden][name=?]",
                    "search_subscription[include_issues]"
      assert_select "input[type=hidden][name=?]",
                    "search_subscription[include_tasks]"
      assert_select "input[type=hidden][name=?]",
                    "search_subscription[issue_type_id]"
      assert_select "input[type=hidden][name=?]",
                    "search_subscription[task_type_id]"
      assert_select "input[type=hidden][name=?]",
                    "search_subscription[issue_status]"
      assert_select "input[type=hidden][name=?]",
                    "search_subscription[task_status]"
    end
  end
end
