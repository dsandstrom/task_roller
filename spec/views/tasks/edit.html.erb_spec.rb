# frozen_string_literal: true

require "rails_helper"

RSpec.describe "tasks/edit", type: :view do
  before(:each) do
    @category = assign(:category, Fabricate(:category))
    @project = assign(:project, Fabricate(:project, category: @category))
    @task_types = assign(:task_types, [Fabricate(:task_type)])
    @task = assign(:task, Fabricate(:task, project: @project))
    assign(:user_options, [["Type 1", [["Name 1", 12], ["Name 2", 14]]]])
    assign(:assignee_options, [["Type 2", [["Name 3", 48], ["Name 4", 8]]]])
  end

  let(:url) { category_project_task_path(@category, @project, @task) }

  it "renders the edit task form" do
    render

    assert_select "form[action=?][method=?]", url, "post" do
      assert_select "input[name=?]", "task[summary]"
      assert_select "textarea[name=?]", "task[description]"
      assert_select "input[name=?]", "task[task_type_id]"
      assert_select "select[name=?]", "task[user_id]"
      assert_select "select[name=?]", "task[assignee_ids][]"
    end
  end
end
