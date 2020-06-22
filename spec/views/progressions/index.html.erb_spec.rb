# frozen_string_literal: true

require "rails_helper"

RSpec.describe "progressions/index", type: :view do
  context "when task has progressions" do
    let(:task) { assign(:task, Fabricate(:task)) }
    let(:first_progression) { Fabricate(:progression, task: task) }
    let(:second_progression) { Fabricate(:progression, task: task) }

    before do
      assign(:progressions, [first_progression, second_progression])
    end

    it "renders a list of progressions" do
      render
      assert_select "#progression_#{first_progression.id}"
      assert_select "#progression_#{second_progression.id}"
    end
  end
end
