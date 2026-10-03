require "rails_helper"

RSpec.describe "project_migrations/index", type: :view do
  let(:project) { Fabricate(:project) }

  before do
    assign(:categories, [project.category])
  end

  it "renders projects" do
    render

    expect(rendered)
      .to have_link(nil, href: new_project_migration_path(project))
  end
end
