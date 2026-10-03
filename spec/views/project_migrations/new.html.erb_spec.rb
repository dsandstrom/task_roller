require "rails_helper"

RSpec.describe "project_migrations/new", type: :view do
  let(:project) { Fabricate(:project) }
  let(:new_project) { Fabricate(:project) }
  let(:path) { project_migrations_path(project) }

  before do
    assign(:project, project)
    assign(:project_options,
           [[new_project.category.name, [new_project.name, new_project.id]]])
  end

  it "renders migration form" do
    render

    assert_select "form[action=?][method=?]", path, "post" do
      assert_select "select[name=?]", "project[migration_id]"
    end
  end
end
