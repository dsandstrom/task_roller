# frozen_string_literal: true

require "rails_helper"

RSpec.describe "task_reopenings/new", type: :view do
  let(:task) { Fabricate(:task) }
  let(:path) { task_reopenings_path(task) }

  before(:each) do
    assign(:task, task)
    assign(:task_reopening, TaskReopening.new(task: task))
  end

  it "renders new task_reopening form" do
    render

    assert_select "form[action=?][method=?]", path, "post"
  end
end
