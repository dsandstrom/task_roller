# frozen_string_literal: true

require "rails_helper"

RSpec.describe "progressions/edit", type: :view do
  let(:project) { Fabricate(:project) }

  before do
    @task = assign(:task, Fabricate(:task, project: project))
    @progression = assign(:progression, Fabricate(:progression, task: @task))
  end

  let(:url) { task_progression_url(@task, @progression) }

  it "renders new progression form" do
    render

    assert_select "form[action=?][method=?]", url, "post" do
      assert_select "select[name=?]", "progression[user_id]"
      assert_select "input[name=?]", "progression[finished]"
    end
  end
end
