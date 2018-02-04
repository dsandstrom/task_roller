# frozen_string_literal: true

require "rails_helper"

RSpec.describe "categories/show", type: :view do
  before(:each) { @category = assign(:category, Fabricate(:category)) }

  context "when it has no projects" do
    before do
      @projects = assign(:projects, [])
      @issues = assign(:issues, [])
    end

    it "renders name" do
      render
      assert_select "h1", @category.name
    end

    it "doesn't render a list of projects" do
      render
      assert_select ".project", count: 0
    end
  end

  context "when it has projects and issues" do
    let(:project) { Fabricate(:project, category: @category) }
    let(:issue) { Fabricate(:issue, project: project) }

    before do
      @projects = assign(:projects, [project])
      @issues = assign(:issues, [issue])
    end

    it "renders a list of projects" do
      render
      assert_select "#project-#{project.id}.project"
    end

    it "renders a list of issues" do
      render
      assert_select "#issue-#{issue.id}.issue"
    end
  end
end
