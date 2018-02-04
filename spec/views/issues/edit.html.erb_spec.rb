# frozen_string_literal: true

require "rails_helper"

RSpec.describe "issues/edit", type: :view do
  before(:each) do
    @category = assign(:category, Fabricate(:category))
    @project = assign(:project, Fabricate(:project, category: @category))
    @issue_types = assign(:issue_types, [Fabricate(:issue_type)])
    @issue = assign(:issue, Fabricate(:issue, project: @project))
    assign(:user_options, [["Type 1", [["Name 1", 12], ["Name 2", 14]]]])
  end

  let(:url) { category_project_issue_path(@category, @project, @issue) }

  it "renders the edit issue form" do
    render

    assert_select "form[action=?][method=?]", url, "post" do
      assert_select "input[name=?]", "issue[summary]"

      assert_select "textarea[name=?]", "issue[description]"

      assert_select "input[name=?]", "issue[issue_type_id]"

      assert_select "select[name=?]", "issue[user_id]"
    end
  end
end
