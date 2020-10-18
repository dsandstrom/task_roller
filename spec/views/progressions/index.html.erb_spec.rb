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

    context "for an admin" do
      let(:admin) { Fabricate(:user_admin) }

      before { enable_pundit(view, admin) }

      it "renders a list of progressions" do
        render
        assert_select "#progression_#{first_progression.id}"
        assert_select "#progression_#{second_progression.id}"
      end

      it "renders edit links" do
        render
        [first_progression, second_progression].each do |progression|
          url = edit_task_progression_path(task, progression)
          expect(rendered).to have_link(nil, href: url)
        end
      end

      it "renders destroy links" do
        render
        [first_progression, second_progression].each do |progression|
          url = task_progression_path(task, progression)
          assert_select "a[href=\"#{url}\"][data-method=\"delete\"]"
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { enable_pundit(view, current_user) }

        it "renders a list of progressions" do
          render
          assert_select "#progression_#{first_progression.id}"
          assert_select "#progression_#{second_progression.id}"
        end

        it "doesn't render edit links" do
          render
          [first_progression, second_progression].each do |progression|
            url = edit_task_progression_path(task, progression)
            expect(rendered).not_to have_link(nil, href: url)
          end
        end

        it "doesn't render destroy links" do
          render
          [first_progression, second_progression].each do |progression|
            url = task_progression_path(task, progression)
            assert_select "a[href=\"#{url}\"][data-method=\"delete\"]",
                          count: 0
          end
        end
      end
    end
  end
end
