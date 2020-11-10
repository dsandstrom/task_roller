# frozen_string_literal: true

require "rails_helper"

RSpec.describe "task_connections/new", type: :view do
  let(:task) { Fabricate(:task) }
  let(:path) { task_connections_path(task) }

  before(:each) do
    assign(:task_connection, TaskConnection.new(source: task))
  end

  it "renders new task_connection form" do
    render

    assert_select "form[action=?][method=?]", path, "post" do
      assert_select "select[name=?]", "task_connection[target_id]"
    end
  end
end
