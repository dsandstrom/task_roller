# frozen_string_literal: true

require "rails_helper"

RSpec.describe "projects/show", type: :view do
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:first_issue) { Fabricate(:issue, project: project) }
  let(:second_issue) { Fabricate(:issue, project: project) }

  before(:each) do
    @category = category
    @project = project
    @issues = [first_issue, second_issue]
  end

  it "renders name" do
    render
    assert_select "h1", @project.name
  end

  it "renders a list of issues" do
    other_issue =
      Fabricate(:issue, project: Fabricate(:project, category: category))

    render
    assert_select "#issue-#{first_issue.id}", count: 1
    assert_select "#issue-#{second_issue.id}", count: 1
    assert_select "#issue-#{other_issue.id}", count: 0
  end
end
