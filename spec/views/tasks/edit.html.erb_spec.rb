require "rails_helper"

RSpec.describe "tasks/edit", type: :view do
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:issue) { Fabricate(:issue, project: project) }

  before(:each) do
    @category = assign(:category, category)
    @project = assign(:project, project)
    @task_types = assign(:task_types, [Fabricate(:task_type)])
    @task = assign(:task, Fabricate(:task, project: @project))
    assign(:user_options, [["Type 1", [["Name 1", 12], ["Name 2", 14]]]])
    assign(:assignee_options, [["Type 2", [["Name 3", 48], ["Name 4", 8]]]])
    assign(:issue_options, [[issue.id_and_summary, issue.id]])
  end

  let(:url) { task_path(@task) }

  context "for a reporter" do
    let(:current_user) { Fabricate(:user_reporter) }

    before { enable_can(view, current_user) }

    it "renders the edit task form" do
      render

      assert_select "form[action=?][method=?]", url, "post" do
        assert_select "input[name=?]", "task[summary]"
        assert_select "textarea[name=?]", "task[description]"
        assert_select "input[name=?]", "task[task_type_id]"
        assert_select "select[name=?]", "task[assignee_ids][]"
      end
    end
  end
end
