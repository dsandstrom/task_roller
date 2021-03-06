# frozen_string_literal: true

require "rails_helper"

RSpec.describe "task_comments/edit", type: :view do
  let(:user) { Fabricate(:user_worker) }
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:task) { Fabricate(:task, project: project) }
  let(:task_comment) { Fabricate(:task_comment, task: task) }

  let(:url) { task_task_comment_url(task, task_comment) }

  context "for the user" do
    before do
      enable_can(view, user)
      assign(:task, task)
      assign(:task_comment, task_comment)
    end

    it "renders the edit task_comment form" do
      render

      assert_select "form[action=?][method=?]", url, "post" do
        assert_select "textarea[name=?]", "task_comment[body]"
      end
    end
  end
end
