require "rails_helper"

RSpec.describe "move_tasks/new", type: :view do
  let(:project) { Fabricate(:project) }
  let(:url) { projects_task_path }

  before do
    assign(:task, project.tasks.build)
    assign(:project_options, [[project.name, project.to_param]])
  end

  context "for a reporter" do
    let(:current_user) { Fabricate(:user_reporter) }

    before { enable_can(view, current_user) }

    it "renders new move_task form" do
      render

      assert_select "form[action=?][method=?]", url, "post" do
        assert_select "select[name=?]", "task[project_id]"
      end
    end

    it "renders turbo_frame" do
      render

      assert_select "turbo-frame[id=?]", "turbo_task_form"
    end

    context "when task_branch unassigned" do
      it "doesn't render form with task_branch fields" do
        render

        assert_select "input[name=?]", "task_branch[source_issue_id]", count: 0
        assert_select "input[name=?]", "task_branch[source_task_id]", count: 0
        assert_select "input[name=?]", "source_issue_id", count: 0
        assert_select "input[name=?]", "source_task_id", count: 0
        assert_select "input[name=?]", "task_branch[issue_comment_id]",
                      count: 0
        assert_select "input[name=?]", "task_branch[task_comment_id]", count: 0
        assert_select "input[name=?]", "issue_comment_id", count: 0
        assert_select "input[name=?]", "task_comment_id", count: 0
      end
    end

    context "when task_branch assigned" do
      before do
        assign(:task_branch, Fabricate.build(:task_branch))
      end

      it "renders form with task_branch fields" do
        render

        assert_select "form[action=?][method=?]", url, "post" do
          assert_select "input[type='hidden'][name=?]",
                        "task_branch[source_issue_id]"
          assert_select "input[type='hidden'][name=?]",
                        "task_branch[issue_comment_id]"
          assert_select "input[type='hidden'][name=?]",
                        "task_branch[source_task_id]"
          assert_select "input[type='hidden'][name=?]",
                        "task_branch[task_comment_id]"
        end
      end
    end
  end
end
