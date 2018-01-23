# frozen_string_literal: true

require "rails_helper"

RSpec.describe "projects/index", type: :view do
  let(:first_project) { Fabricate(:project) }
  let(:second_project) { Fabricate(:project) }

  before(:each) { assign(:projects, [first_project, second_project]) }

  it "renders a list of projects" do
    render
    assert_select "#project-#{first_project.id}"
    assert_select "#project-#{second_project.id}"
  end
end
