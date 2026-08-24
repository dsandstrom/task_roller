require "rails_helper"

RSpec.describe "task_type_migrations/new", type: :view do
  let(:task_type) { Fabricate(:task_type) }
  let(:new_task_type) { Fabricate(:task_type) }
  let(:path) { task_type_migrations_path(task_type) }

  before do
    assign(:task_type, task_type)
  end

  context "when other task_types" do
    before do
      assign(:task_types, [new_task_type])
    end

    it "renders migration form" do
      render

      assert_select "form[action=?][method=?]", path, "post" do
        assert_select "select[name=?]", "task_type[new_task_type_id]"
      end
    end
  end

  context "when no other task_types" do
    before do
      assign(:task_types, [])
    end

    it "doesn't render a form" do
      render

      assert_select "form", count: 0
    end
  end
end
