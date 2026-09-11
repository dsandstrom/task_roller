require "rails_helper"

RSpec.describe "issues/new", type: :view do
  let(:category) { Fabricate(:category) }
  let(:first_project) { Fabricate(:project, category: category) }
  let(:second_project) { Fabricate(:project, category: category) }
  let(:issue_type) { Fabricate(:issue_type) }
  let(:url) { issues_path }

  before do
    assign(:issue_types, [issue_type])
    assign(:issue, Issue.new)
    assign(:project_options,
           [[category.name, [[first_project.name, first_project.id],
                             [second_project.name, second_project.id]]]])
  end

  context "for a reporter" do
    let(:current_user) { Fabricate(:user_reporter) }

    before { enable_can(view, current_user) }

    it "renders new issue form" do
      render

      assert_select "form[action=?][method=?]", url, "post" do
        assert_select "input[name=?]", "issue[summary]"

        assert_select "select[name=?]", "issue[project_id]"

        assert_select "textarea[name=?]", "issue[description]"

        assert_select "input[name=?]", "issue[issue_type_id]"
      end
    end

    context "when issue_branch unassigned" do
      it "doesn't render form with hidden fields" do
        render

        assert_select "input[type='hidden'][name=?]", "issue_branch[source_issue_id]", count: 0
        assert_select "input[type='hidden'][name=?]", "issue_branch[source_task_id]", count: 0
        assert_select "input[type='hidden'][name=?]", "source_issue_id", count: 0
        assert_select "input[type='hidden'][name=?]", "source_task_id", count: 0
      end
    end

    context "when issue_branch assigned" do
      before do
        assign(:issue_branch, Fabricate.build(:issue_branch))
      end

      it "renders form with hidden fields" do
        render

        assert_select "form[action=?][method=?]", url, "post" do
          assert_select "input[type='hidden'][name=?]", "issue_branch[source_issue_id]"
          assert_select "input[type='hidden'][name=?]", "issue_branch[source_task_id]"
        end
      end
    end
  end
end
