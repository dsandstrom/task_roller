# frozen_string_literal: true

require "rails_helper"

RSpec.describe "issue_types/index", type: :view do
  let(:first_issue_type) { Fabricate(:issue_type) }
  let(:second_issue_type) { Fabricate(:issue_type) }
  let(:first_task_type) { Fabricate(:task_type) }
  let(:second_task_type) { Fabricate(:task_type) }

  before(:each) do
    assign(:issue_types, [first_issue_type, second_issue_type])
    assign(:task_types, [first_task_type, second_task_type])
  end

  it "renders a list of issue_types" do
    render
    assert_select "#issue-type-#{first_issue_type.id}", count: 1
    assert_select "#issue-type-#{second_issue_type.id}", count: 1
    assert_select "#task-type-#{first_task_type.id}", count: 1
    assert_select "#task-type-#{second_task_type.id}", count: 1
  end
end
