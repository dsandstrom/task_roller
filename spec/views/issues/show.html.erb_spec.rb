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
      assert_select ".issue-summary", "Issue: #{@issue.summary}"
    end
  end

  context "when no project" do
    before do
      project = Fabricate(:project, category: @category)
      @issue = assign(:issue, Fabricate(:issue, project: project))
    end

    it "renders summary>" do
      render
      assert_select ".issue-summary", "Issue: #{@issue.summary}"
    end
  end

  context "when no issue_type" do
    before do
      @project = assign(:project, Fabricate(:project, category: @category))
      @issue = assign(:issue, Fabricate(:issue, project: @project))
      @issue.issue_type.destroy
      @issue.reload
    end

    it "renders summary>" do
      render
      assert_select ".issue-summary", "Issue: #{@issue.summary}"
    end
  end
end
