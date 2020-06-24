# frozen_string_literal: true

require "rails_helper"

RSpec.describe "task_comments/edit", type: :view do
  let(:user) { Fabricate(:user_worker) }
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:task) { Fabricate(:task, project: project) }
  let(:task_comment) { Fabricate(:task_comment, task: task) }

  let(:url) do
    category_project_task_task_comment_url(category, project, task,
                                           task_comment)
  end

  before(:each) do
    assign(:category, category)
    assign(:project, project)
    assign(:task, task)
    assign(:task_comment, task_comment)
  end

  it "renders the edit task_comment form" do
    render

    assert_select "form[action=?][method=?]", url, "post" do
      assert_select "select[name=?]", "task_comment[user_id]"

      assert_select "textarea[name=?]", "task_comment[body]"
    end
  end
end
