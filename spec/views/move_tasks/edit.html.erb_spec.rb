require "rails_helper"

RSpec.describe "move_tasks/edit", type: :view do
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:new_project) { Fabricate(:project, category: category) }

  before(:each) do
    @task = assign(:task, Fabricate(:task, project: project))
    assign(
      :project_options,
      [[category.name_and_tag, [new_project.name_and_tag, new_project.id]]]
    )
  end

  context "for a reviewer" do
    let(:current_user) { Fabricate(:user_reviewer) }

    before { enable_can(view, current_user) }

    it "renders move_task form" do
      render

      url = move_task_path(@task)
      assert_select "form[action=?]", url do
        assert_select "select[name=?]", "task[project_id]"
      end
    end
  end
end
