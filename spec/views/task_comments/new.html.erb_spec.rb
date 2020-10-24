# frozen_string_literal: true

require "rails_helper"

RSpec.describe "task_comments/new", type: :view do
  let(:user) { Fabricate(:user_worker) }
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:task) { Fabricate(:task, project: project) }

  let(:url) { task_task_comments_url(task) }

  before(:each) do
    assign(:category, category)
    assign(:project, project)
    assign(:task, task)
    assign(:task_comment, task.comments.build)
  end

  it "renders new task_comment form" do
    render

    assert_select "form[action=?][method=?]", url, "post" do
      assert_select "textarea[name=?]", "task_comment[body]"
    end
  end
end
