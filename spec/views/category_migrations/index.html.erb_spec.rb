require "rails_helper"

RSpec.describe "category_migrations/index", type: :view do
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }

  before do
    assign(:categories, [project.category])
  end

  it "renders categories" do
    render

    expect(rendered)
      .to have_link(nil, href: new_category_migration_path(category))
  end

  it "renders projects" do
    render

    expect(rendered)
      .to have_link(nil, href: new_project_migration_path(project))
  end
end
