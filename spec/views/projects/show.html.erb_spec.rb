# frozen_string_literal: true

require "rails_helper"

RSpec.describe "projects/show", type: :view do
  before(:each) do
    @category = assign(:category, Fabricate(:category))
    @project = assign(:project, Fabricate(:project, category: @category))
  end

  it "renders name" do
    render
    assert_select "h1", @project.name
  end
end
