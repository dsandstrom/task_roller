# frozen_string_literal: true

require "rails_helper"

RSpec.describe "issues/index", type: :view do
  context "when no category and project" do
    let(:first_issue) { Fabricate(:issue) }
    let(:second_issue) { Fabricate(:issue) }

    before(:each) { assign(:issues, [first_issue, second_issue]) }

    it "renders a list of issues" do
      render
      assert_select "#issue-#{first_issue.id}"
      assert_select "#issue-#{second_issue.id}"
    end
  end

  context "when only category" do
    let(:category) { Fabricate(:category) }
    let(:first_issue) do
      Fabricate(:issue, project: Fabricate(:project, category: category))
    end
    let(:second_issue) do
      Fabricate(:issue, project: Fabricate(:project, category: category))
    end

    before(:each) do
      assign(:category, category)
      assign(:issues, [first_issue, second_issue])
    end

    it "renders a list of issues" do
      render
      assert_select "#issue-#{first_issue.id}"
      assert_select "#issue-#{second_issue.id}"
    end
  end

  context "when project" do
    let(:category) { Fabricate(:category) }
    let(:project) { Fabricate(:project) }
    let(:first_issue) { Fabricate(:issue, project: project) }
    let(:second_issue) { Fabricate(:issue, project: project) }

    before(:each) do
      assign(:category, category)
      assign(:project, project)
      assign(:issues, [first_issue, second_issue])
    end

    it "renders a list of issues" do
      render
      assert_select "#issue-#{first_issue.id}"
      assert_select "#issue-#{second_issue.id}"
    end
  end
end
