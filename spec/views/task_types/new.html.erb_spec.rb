# frozen_string_literal: true

require "rails_helper"

RSpec.describe "task_types/new", type: :view do
  before(:each) { assign(:task_type, TaskType.new) }

  it "renders new task_type form" do
    render

    assert_select "form[action=?][method=?]", task_types_path, "post" do
      assert_select "input[name=?]", "task_type[name]"

      assert_select "input[name=?]", "task_type[icon]"

      assert_select "input[name=?]", "task_type[color]"
    end
  end
end
