# frozen_string_literal: true

require "rails_helper"

RSpec.describe "projects/index", type: :view do
  let(:admin) { Fabricate(:user_admin) }
  let(:first_project) { Fabricate(:project) }
  let(:second_project) { Fabricate(:project) }

  before { assign(:projects, [first_project, second_project]) }

  context "for an admin" do
    before { enable_pundit(view, admin) }

    it "renders a list of projects" do
      render

      [first_project, second_project].each do |project|
        assert_select "#project-#{project.id}"
        assert_select "#project-#{project.id} a[data-method=\"delete\"]"
        edit_url = edit_category_project_path(project.category, project)
        expect(rendered).to have_link(nil, href: edit_url)
      end
    end
  end
end
