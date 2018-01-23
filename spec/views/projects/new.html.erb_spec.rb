# frozen_string_literal: true

require "rails_helper"

RSpec.describe "projects/new", type: :view do
  let(:category) { Fabricate(:category) }
  let(:path) { category_projects_path(category) }

  before(:each) do
    assign(:category, category)
    assign(:project, category.projects.build)
  end

  it "renders new project form" do
    render

    assert_select "form[action=?][method=?]", path, "post" do
      assert_select "input[name=?]", "project[name]"
      assert_select "input[name=?]", "project[visible]"
      assert_select "input[name=?]", "project[internal]"
      assert_select "input[name=?]", "project[category_id]", count: 0
    end
  end
end
