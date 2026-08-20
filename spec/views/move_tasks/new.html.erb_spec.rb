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
  end
end
