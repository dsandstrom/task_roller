# frozen_string_literal: true

require "rails_helper"

RSpec.describe "issues/new", type: :view do
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:issue_type) { Fabricate(:issue_type) }
  let(:url) { category_project_issues_path(category, project) }

  before(:each) do
    assign(:category, category)
    assign(:project, project)
    assign(:issue_types, [issue_type])
    assign(:issue, project.issues.build)
  end

  it "renders new issue form" do
    render

    assert_select "form[action=?][method=?]", url, "post" do
      assert_select "input[name=?]", "issue[summary]"

      assert_select "textarea[name=?]", "issue[description]"

      assert_select "input[name=?]", "issue[issue_type_id]"

      assert_select "select[name=?]", "issue[user_id]"
    end
  end
end
