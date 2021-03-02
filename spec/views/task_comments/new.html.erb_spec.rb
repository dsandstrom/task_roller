# frozen_string_literal: true

require "rails_helper"

RSpec.describe "task_comments/new", type: :view do
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:task) { Fabricate(:task, project: project) }

  let(:url) { task_task_comments_url(task) }

  context "for a reviewer" do
    let(:current_user) { Fabricate(:user_reviewer) }

    before do
      enable_can(view, current_user)
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
end
