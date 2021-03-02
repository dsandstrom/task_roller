# frozen_string_literal: true

require "rails_helper"

RSpec.describe "projects/edit", type: :view do
  let(:category) { Fabricate(:category) }
  let(:form_path) { project_path(@project) }

  before(:each) do
    @category = assign(:category, category)
    @project = assign(:project, Fabricate(:project, category: @category))
  end

  context "for a reviewer" do
    let(:current_user) { Fabricate(:user_reviewer) }

    before { enable_can(view, current_user) }

    it "renders the edit project form" do
      render

      assert_select "form[action=?][method=?]", form_path, "post" do
        assert_select "input[name=?]", "project[name]"
        assert_select "input[name=?]", "project[visible]"
        assert_select "input[name=?]", "project[internal]"
        assert_select "select[name=?]", "project[category_id]"
      end
    end
  end
end
