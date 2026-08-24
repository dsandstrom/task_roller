require "rails_helper"

RSpec.describe "issue_type_migrations/new", type: :view do
  let(:issue_type) { Fabricate(:issue_type) }
  let(:new_issue_type) { Fabricate(:issue_type) }
  let(:path) { issue_type_migrations_path(issue_type) }

  before do
    assign(:issue_type, issue_type)
  end

  context "when other issue_types" do
    before do
      assign(:issue_types, [new_issue_type])
    end

    it "renders migration form" do
      render

      assert_select "form[action=?][method=?]", path, "post" do
        assert_select "select[name=?]", "issue_type[new_issue_type_id]"
      end
    end
  end

  context "when no other issue_types" do
    before do
      assign(:issue_types, [])
    end

    it "doesn't render a form" do
      render

      assert_select "form", count: 0
    end
  end
end
