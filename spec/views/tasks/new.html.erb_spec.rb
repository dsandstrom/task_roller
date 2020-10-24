# frozen_string_literal: true

require "rails_helper"

RSpec.describe "tasks/new", type: :view do
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:task_type) { Fabricate(:task_type) }
  let(:url) { project_tasks_path(project) }

  before(:each) do
    assign(:category, category)
    assign(:project, project)
    assign(:task_types, [task_type])
    assign(:task, project.tasks.build)
    assign(:user_options, [["Type 1", [["Name 1", 12], ["Name 2", 14]]]])
    assign(:assignee_options, [["Type 2", [["Name 3", 48], ["Name 4", 8]]]])
  end

  it "renders new task form" do
    render

    assert_select "form[action=?][method=?]", url, "post" do
      assert_select "input[name=?]", "task[summary]"
      assert_select "textarea[name=?]", "task[description]"
      assert_select "input[name=?]", "task[task_type_id]"
      assert_select "select[name=?]", "task[assignee_ids][]"
    end
  end
end
