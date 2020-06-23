# frozen_string_literal: true

require "rails_helper"

RSpec.describe "reviews/edit", type: :view do
  let(:project) { Fabricate(:project) }

  before do
    @task = assign(:task, Fabricate(:task, project: project))
    @review = assign(:review, Fabricate(:review, task: @task))
  end

  let(:url) { task_review_url(@task, @review) }

  it "renders new review form" do
    render

    assert_select "form[action=?][method=?]", url, "post" do
      assert_select "select[name=?]", "review[user_id]"
      assert_select "input[name=?]", "review[approved]"
    end
  end
end
