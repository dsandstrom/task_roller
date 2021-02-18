# frozen_string_literal: true

require "rails_helper"

RSpec.describe "searches/new", type: :view do
  it "renders new search form" do
    render

    assert_select "form[action=?][method=?]", search_results_path, "get" do
      assert_select "input[name=?]", "query"
      assert_select "input[name=?]", "order"
    end
  end

  it "doesn't render reset link" do
    render

    expect(rendered).not_to have_link(nil, href: search_path)
  end
end
