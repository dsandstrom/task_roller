# frozen_string_literal: true

require "rails_helper"

RSpec.describe "projects/edit", type: :view do
  let(:category) { Fabricate(:category) }
  let(:form_path) { category_project_path(@category, @project) }

  before(:each) do
    @category = assign(:category, category)
    @project = assign(:project, Fabricate(:project, category: @category))
  end

  it "renders the edit project form" do
    render

    assert_select "form[action=?][method=?]", form_path, "post" do
      assert_select "input[name=?]", "project[name]"
      assert_select "input[name=?]", "project[visible]"
      assert_select "input[name=?]", "project[internal]"
      assert_select "input[name=?]", "project[category_id]", count: 0
    end
  end
end
