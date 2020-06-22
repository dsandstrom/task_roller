# frozen_string_literal: true

require "rails_helper"

RSpec.describe "task_assignments/edit", type: :view do
  before(:each) do
    @category = assign(:category, Fabricate(:category))
    @project = assign(:project, Fabricate(:project, category: @category))
    @task = assign(:task, Fabricate(:task, project: @project))
  end

  let(:url) { task_assignment_path(@task) }

  it "renders the edit task form" do
    render

    assert_select "form[action=?][method=?]", url, "post" do
      assert_select "select[name=?]", "task[assignee_ids][]"
    end
  end
end
