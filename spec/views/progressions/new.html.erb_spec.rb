# frozen_string_literal: true

require "rails_helper"

RSpec.describe "progressions/new", type: :view do
  let(:task) { assign(:task, Fabricate(:task)) }
  let(:url) { task_progressions_url(task) }

  context "for an admin" do
    let(:current_user) { Fabricate(:user_admin) }

    before(:each) do
      enable_can(view, current_user)
      assign(:progression, task.progressions.build)
    end

    it "renders new progression form" do
      render

      assert_select "form[action=?][method=?]", url, "post" do
        assert_select "select[name=?]", "progression[user_id]"
        assert_select "input[name=?]", "progression[finished]"
      end
    end
  end
end
