require "rails_helper"

RSpec.describe "issues/edit", type: :view do
  let(:project) { Fabricate(:project) }

  before(:each) do
    @issue_types = assign(:issue_types, [Fabricate(:issue_type)])
    @issue = assign(:issue, Fabricate(:issue, project: project))
  end

  let(:url) { issue_path(@issue) }

  context "for a reporter" do
    let(:current_user) { Fabricate(:user_reporter) }

    before { enable_can(view, current_user) }

    it "renders the edit issue form" do
      render

      assert_select "form[action=?][method=?]", url, "post" do
        assert_select "input[name=?]", "issue[summary]"

        assert_select "textarea[name=?]", "issue[description]"

        assert_select "input[name=?]", "issue[issue_type_id]"
      end
    end

    it "doesn't render form with issue_branch fields" do
      render

      assert_select "input[name=?]", "issue_branch[source_issue_id]", count: 0
      assert_select "input[name=?]", "issue_branch[source_task_id]", count: 0
      assert_select "input[name=?]", "source_issue_id", count: 0
      assert_select "input[name=?]", "source_task_id", count: 0
      assert_select "input[name=?]", "issue_branch[issue_comment_id]",
                    count: 0
      assert_select "input[name=?]", "issue_branch[task_comment_id]", count: 0
      assert_select "input[name=?]", "issue_comment_id", count: 0
      assert_select "input[name=?]", "task_comment_id", count: 0
    end
  end
end
