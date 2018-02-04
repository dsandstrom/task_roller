# frozen_string_literal: true

require "rails_helper"

RSpec.describe "issues/show", type: :view do
  before(:each) { @category = assign(:category, Fabricate(:category)) }

  context "when project" do
    before do
      @project = assign(:project, Fabricate(:project, category: @category))
      @issue = assign(:issue, Fabricate(:issue, project: @project))
    end

    it "renders summary>" do
      render
      assert_select ".issue-summary", @issue.summary
    end
  end

  context "when no project" do
    before do
      project = Fabricate(:project, category: @category)
      @issue = assign(:issue, Fabricate(:issue, project: project))
    end

    it "renders summary>" do
      render
      assert_select ".issue-summary", @issue.summary
    end
  end
end
