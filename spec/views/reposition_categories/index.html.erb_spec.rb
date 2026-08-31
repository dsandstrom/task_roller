require "rails_helper"

RSpec.describe "reposition_categories/index", type: :view do
  let(:subject) { "reposition_categories/index" }
  let(:first_category) { Fabricate(:category) }
  let(:second_category) { Fabricate(:internal_category) }
  let(:third_category) { Fabricate(:invisible_category) }

  before do
    assign(:categories, [first_category, second_category, third_category])
  end

  %w[admin reviewer].each do |employee_type|
    context "for a #{employee_type}" do
      let(:current_user) { Fabricate("user_#{employee_type}") }

      before { enable_can(view, current_user) }

      it "renders a list of categories" do
        render

        assert_select "#category-#{first_category.id} .category-name h3",
                      text: first_category.name
        assert_select "#category-#{second_category.id} .category-name h3",
                      text: second_category.name
        assert_select "#category-#{third_category.id} .category-name h3",
                      text: third_category.name
      end
    end
  end
end
