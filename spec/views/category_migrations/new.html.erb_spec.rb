require "rails_helper"

RSpec.describe "category_migrations/new", type: :view do
  let(:category) { Fabricate(:category) }
  let(:new_category) { Fabricate(:category) }
  let(:path) { category_migrations_path(category) }

  before do
    assign(:category, category)
    assign(:categories, [new_category])
  end

  it "renders migration form" do
    render

    assert_select "form[action=?][method=?]", path, "post" do
      assert_select "select[name=?]", "category[migration_id]"
    end
  end
end
