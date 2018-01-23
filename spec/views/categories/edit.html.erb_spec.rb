# frozen_string_literal: true

require "rails_helper"

RSpec.describe "categories/edit", type: :view do
  before(:each) { @category = assign(:category, Fabricate(:category)) }

  let(:path) { category_path(@category) }

  it "renders the edit category form" do
    render

    assert_select "form[action=?][method=?]", path, "post" do
      assert_select "input[name=?]", "category[name]"

      assert_select "input[name=?]", "category[visible]"

      assert_select "input[name=?]", "category[internal]"
    end
  end
end
