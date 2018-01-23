# frozen_string_literal: true

require "rails_helper"

RSpec.describe "categories/show", type: :view do
  before(:each) { @category = assign(:category, Fabricate(:category)) }

  it "renders name" do
    render

    assert_select "h1", @category.name
  end
end
