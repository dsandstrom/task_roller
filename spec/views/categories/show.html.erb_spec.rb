# frozen_string_literal: true

require "rails_helper"

RSpec.describe "categories/show", type: :view do
  before(:each) { @category = assign(:category, Fabricate(:category)) }

  context "when it has no projects" do
    before { @projects = assign(:projects, []) }

    it "renders name" do
      render
      assert_select "h1", @category.name
    end

    it "doesn't render a list of projects" do
      render
      assert_select ".project", count: 0
    end
  end

  context "when it has projects" do
    let(:project) { Fabricate(:project, category: @category) }

    before { @projects = assign(:projects, [project]) }

    it "renders a list of projects" do
      render
      assert_select "#project-#{project.id}.project"
    end
  end
end
