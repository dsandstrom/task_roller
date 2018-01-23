# frozen_string_literal: true

require "rails_helper"

RSpec.describe "categories/index", type: :view do
  let(:first_category) { Fabricate(:category) }
  let(:second_category) { Fabricate(:category) }

  before(:each) { assign(:categories, [first_category, second_category]) }

  it "renders a list of categories" do
    render
    assert_select "#category-#{first_category.id} .category-name",
                  text: first_category.name
    assert_select "#category-#{second_category.id} .category-name",
                  text: second_category.name
  end
end
