# frozen_string_literal: true

require "rails_helper"

RSpec.describe "task_types/edit", type: :view do
  let(:task_type) { Fabricate(:task_type) }
  let(:url) { task_type_path(task_type) }

  before(:each) { @task_type = assign(:task_type, task_type) }

  it "renders the edit task_type form" do
    render

    assert_select "form[action=?][method=?]", url, "post" do
      assert_select "input[name=?]", "task_type[name]"

      assert_select "input[name=?]", "task_type[icon]"

      assert_select "input[name=?]", "task_type[color]"
    end
  end
end
