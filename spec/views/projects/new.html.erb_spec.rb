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

  context "when category is internal" do
    let(:category) { Fabricate(:internal_category) }

    it "renders the edit project form" do
      render

      assert_select "form[action=?][method=?]", path, "post" do
        assert_select "input[name=?]", "project[name]"
        assert_select "input[name=?]", "project[visible]"
        assert_select "input[name=?]", "project[internal]", count: 0
        assert_select "select[name=?]", "project[category_id]"
      end
    end
  end

  context "when category is invisible" do
    let(:category) { Fabricate(:invisible_category) }

    it "renders the edit project form" do
      render

      assert_select "form[action=?][method=?]", path, "post" do
        assert_select "input[name=?]", "project[name]"
        assert_select "input[name=?]", "project[visible]", count: 0
        assert_select "input[name=?]", "project[internal]"
        assert_select "select[name=?]", "project[category_id]"
      end
    end
  end

  context "when category is internal & invisible" do
    let(:category) { Fabricate(:invisible_category, internal: true) }

    it "renders the edit project form" do
      render

      assert_select "form[action=?][method=?]", path, "post" do
        assert_select "input[name=?]", "project[name]"
        assert_select "input[name=?]", "project[visible]", count: 0
        assert_select "input[name=?]", "project[internal]", count: 0
        assert_select "select[name=?]", "project[category_id]"
      end
    end
  end
end
