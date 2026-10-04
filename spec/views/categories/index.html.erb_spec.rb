require "rails_helper"

RSpec.describe "categories/index", type: :view do
  let(:subject) { "categories/index" }
  let(:first_category) { Fabricate(:category) }
  let(:second_category) { Fabricate(:category) }

  before(:each) { assign(:categories, [first_category, second_category]) }

  context "for an admin" do
    let(:admin) { Fabricate(:user_admin) }

    before do
      enable_can(view, admin)
      Fabricate(:project, category: first_category)
    end

    it "renders a list of categories" do
      render

      assert_select "#category-#{first_category.id} .category-name",
                    text: first_category.name
      expect(rendered)
        .to have_link(nil, href: edit_category_path(first_category))
      expect(rendered)
        .to have_link(nil, href: new_category_migration_path(first_category))
      assert_select "#category-#{first_category.id} a[data-method=\"delete\"]",
                    count: 0

      assert_select "#category-#{second_category.id} .category-name",
                    text: second_category.name
      expect(rendered)
        .to have_link(nil, href: edit_category_path(second_category))
      expect(rendered).not_to have_link(
        nil,
        href: new_category_migration_path(second_category)
      )
      assert_select "#category-#{second_category.id} a[data-method=\"delete\"]"
    end

    it "renders new category link" do
      render template: subject, layout: "layouts/application"

      expect(rendered).to have_link(nil, href: new_category_path)
    end

    context "when an archived category" do
      it "renders archived categories link" do
        Fabricate(:invisible_category)

        render template: subject, layout: "layouts/application"

        expect(rendered).to have_link(nil, href: archived_categories_path)
      end
    end

    context "when no archived categories" do
      it "doesn't render archived categories link" do
        render template: subject, layout: "layouts/application"

        expect(rendered).not_to have_link(nil, href: archived_categories_path)
      end
    end

    it "renders new issue menu link" do
      render template: subject, layout: "layouts/application"

      expect(rendered).to have_link(nil, href: new_issue_path)
    end

    it "renders new task menu link" do
      render template: subject, layout: "layouts/application"

      expect(rendered).to have_link(nil, href: new_projects_task_path)
    end

    it "renders reviews menu link" do
      render template: subject, layout: "layouts/application"

      expect(rendered).to have_link(nil, href: finished_tasks_path)
    end
  end

  context "for a reviewer" do
    let(:reviewer) { Fabricate(:user_reviewer) }

    before { enable_can(view, reviewer) }

    it "renders a list of categories" do
      render

      [first_category, second_category].each do |category|
        assert_select "#category-#{category.id} .category-name",
                      text: category.name
        expect(rendered).to have_link(nil, href: edit_category_path(category))
        assert_select "#category-#{category.id} a[data-method=\"delete\"]",
                      count: 0
        expect(rendered)
          .not_to have_link(nil, href: new_category_migration_path(category))
      end
    end

    it "render new category link" do
      render template: subject, layout: "layouts/application"

      expect(rendered).to have_link(nil, href: new_category_path)
    end

    context "when an archived category" do
      it "renders archived categories link" do
        Fabricate(:invisible_category)

        render template: subject, layout: "layouts/application"

        expect(rendered).to have_link(nil, href: archived_categories_path)
      end
    end

    context "when no archived categories" do
      it "doesn't render archived categories link" do
        render template: subject, layout: "layouts/application"

        expect(rendered).not_to have_link(nil, href: archived_categories_path)
      end
    end

    it "renders new issue menu link" do
      render template: subject, layout: "layouts/application"

      expect(rendered).to have_link(nil, href: new_issue_path)
    end

    it "renders new task menu link" do
      render template: subject, layout: "layouts/application"

      expect(rendered).to have_link(nil, href: new_projects_task_path)
    end

    it "renders reviews menu link" do
      render template: subject, layout: "layouts/application"

      expect(rendered).to have_link(nil, href: finished_tasks_path)
    end
  end

  %w[worker reporter].each do |employee_type|
    context "for a #{employee_type}" do
      let(:current_user) { Fabricate("user_#{employee_type}") }

      before { enable_can(view, current_user) }

      it "renders a list of categories" do
        render

        [first_category, second_category].each do |category|
          assert_select "#category-#{category.id} .category-name",
                        text: category.name
          assert_select "#category-#{category.id} .category-name",
                        text: category.name

          expect(rendered)
            .not_to have_link(nil, href: edit_category_path(category))
          assert_select "#category-#{category.id} a[data-method=\"delete\"]",
                        count: 0
        end
      end

      it "doesn't render a new category link" do
        render template: subject, layout: "layouts/application"

        expect(rendered).not_to have_link(nil, href: new_category_path)
      end

      it "doesn't render archived categories link" do
        Fabricate(:invisible_category)

        render template: subject, layout: "layouts/application"

        expect(rendered).not_to have_link(nil, href: archived_categories_path)
      end

      it "renders new issue menu link" do
        render template: subject, layout: "layouts/application"

        expect(rendered).to have_link(nil, href: new_issue_path)
      end

      it "doesn't render new task menu link" do
        render template: subject, layout: "layouts/application"

        expect(rendered).not_to have_link(nil, href: new_projects_task_path)
      end

      it "doesn't render reviews menu link" do
        render template: subject, layout: "layouts/application"

        expect(rendered).not_to have_link(nil, href: finished_tasks_path)
      end
    end
  end
end
