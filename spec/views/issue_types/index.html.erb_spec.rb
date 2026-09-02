require "rails_helper"

RSpec.describe "issue_types/index", type: :view do
  let(:first_issue_type) { Fabricate(:issue_type) }
  let(:second_issue_type) { Fabricate(:issue_type) }
  let(:first_task_type) { Fabricate(:task_type) }
  let(:second_task_type) { Fabricate(:task_type) }
  let(:admin) { Fabricate(:user_admin) }
  let(:reviewer) { Fabricate(:user_reviewer) }

  before do
    Fabricate(:issue, issue_type: first_issue_type)
    Fabricate(:task, task_type: first_task_type)

    assign(:issue_types, [first_issue_type, second_issue_type])
    assign(:task_types, [first_task_type, second_task_type])
  end

  context "for an admin" do
    before { enable_can(view, admin) }

    it "renders a list of issue_types" do
      first_url = reposition_issue_type_url(first_issue_type.to_param)
      second_url = reposition_issue_type_url(second_issue_type.to_param)

      render

      assert_select(
        "#issue-type-#{first_issue_type.id}[data-sortable-url='#{first_url}']",
        count: 1
      )
      assert_select(
        "#issue-type-#{second_issue_type.id}" \
        "[data-sortable-url='#{second_url}']",
        count: 1
      )
    end

    it "renders a list of task_types" do
      first_url = reposition_task_type_url(first_task_type.to_param)
      second_url = reposition_task_type_url(second_task_type.to_param)

      render

      assert_select(
        "#task-type-#{first_task_type.id}[data-sortable-url='#{first_url}']",
        count: 1
      )
      assert_select(
        "#task-type-#{second_task_type.id}[data-sortable-url='#{second_url}']",
        count: 1
      )
    end

    it "renders new type links" do
      render

      expect(rendered).to have_link(nil, href: new_issue_type_path)
      expect(rendered).to have_link(nil, href: new_task_type_path)
    end

    context "when issue_type has an issue" do
      it "renders migration link" do
        render

        expect(rendered).to have_link(
          nil,
          href: new_issue_type_migration_path(first_issue_type)
        )
      end

      it "doesn't render destroy link" do
        render

        expect(rendered).not_to have_link(
          nil,
          href: issue_type_path(first_issue_type)
        )
      end
    end

    context "when issue_type doesn't have an issue" do
      it "doesn't render migration link" do
        render

        expect(rendered).not_to have_link(
          nil,
          href: new_issue_type_migration_path(second_issue_type)
        )
      end

      it "renders destroy link" do
        render

        expect(rendered).to have_link(
          nil,
          href: issue_type_path(second_issue_type)
        )
      end
    end

    context "when task_type has an task" do
      it "renders migration link" do
        render

        expect(rendered).to have_link(
          nil,
          href: new_task_type_migration_path(first_task_type)
        )
      end

      it "doesn't render destroy link" do
        render

        expect(rendered).not_to have_link(
          nil,
          href: task_type_path(first_task_type)
        )
      end
    end

    context "when task_type doesn't have an task" do
      it "doesn't render migration link" do
        render

        expect(rendered).not_to have_link(
          nil,
          href: new_task_type_migration_path(second_task_type)
        )
      end

      it "renders destroy link" do
        render

        expect(rendered).to have_link(
          nil,
          href: task_type_path(second_task_type)
        )
      end
    end
  end

  context "for an reviewer" do
    before { enable_can(view, reviewer) }

    it "renders a list of issue_types" do
      first_url = reposition_issue_type_url(first_issue_type.to_param)
      second_url = reposition_issue_type_url(second_issue_type.to_param)

      render

      assert_select(
        "#issue-type-#{first_issue_type.id}[data-sortable-url='#{first_url}']",
        count: 1
      )
      assert_select(
        "#issue-type-#{second_issue_type.id}" \
        "[data-sortable-url='#{second_url}']",
        count: 1
      )
    end

    it "renders a list of task_types" do
      first_url = reposition_task_type_url(first_task_type.to_param)
      second_url = reposition_task_type_url(second_task_type.to_param)

      render

      assert_select(
        "#task-type-#{first_task_type.id}[data-sortable-url='#{first_url}']",
        count: 1
      )
      assert_select(
        "#task-type-#{second_task_type.id}[data-sortable-url='#{second_url}']",
        count: 1
      )
    end

    it "renders new type links" do
      render

      expect(rendered).to have_link(nil, href: new_issue_type_path)
      expect(rendered).to have_link(nil, href: new_task_type_path)
    end

    context "when issue_type has an issue" do
      it "doesn't render migration link" do
        render

        expect(rendered).not_to have_link(
          nil,
          href: new_issue_type_migration_path(first_issue_type)
        )
      end

      it "doesn't render destroy link" do
        render

        expect(rendered).not_to have_link(
          nil,
          href: issue_type_path(first_issue_type)
        )
      end
    end

    context "when issue_type doesn't have an issue" do
      it "doesn't render migration link" do
        render

        expect(rendered).not_to have_link(
          nil,
          href: new_issue_type_migration_path(second_issue_type)
        )
      end

      it "doesn't render destroy link" do
        render

        expect(rendered).not_to have_link(
          nil,
          href: issue_type_path(second_issue_type)
        )
      end
    end

    context "when task_type has an task" do
      it "doesn't render migration link" do
        render

        expect(rendered).not_to have_link(
          nil,
          href: new_task_type_migration_path(first_task_type)
        )
      end

      it "doesn't render destroy link" do
        render

        expect(rendered).not_to have_link(
          nil,
          href: task_type_path(first_task_type)
        )
      end
    end

    context "when task_type doesn't have an task" do
      it "doesn't render migration link" do
        render

        expect(rendered).not_to have_link(
          nil,
          href: new_task_type_migration_path(second_task_type)
        )
      end

      it "doesn't render destroy link" do
        render

        expect(rendered).not_to have_link(
          nil,
          href: task_type_path(second_task_type)
        )
      end
    end
  end
end
