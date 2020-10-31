# frozen_string_literal: true

require "rails_helper"

RSpec.describe "users/index", type: :view do
  let(:first_user_admin) { Fabricate(:user_admin) }
  let(:second_user_admin) { Fabricate(:user_admin) }
  let(:first_user_reporter) { Fabricate(:user_reporter) }
  let(:second_user_reporter) { Fabricate(:user_reporter) }
  let(:first_user_reviewer) { Fabricate(:user_reviewer) }
  let(:second_user_reviewer) { Fabricate(:user_reviewer) }
  let(:first_user_worker) { Fabricate(:user_worker) }
  let(:second_user_worker) { Fabricate(:user_worker) }

  before(:each) do
    assign(:admins, [first_user_admin, second_user_admin])
    assign(:reviewers, [first_user_reviewer, second_user_reviewer])
    assign(:reporters, [first_user_reporter, second_user_reporter])
    assign(:workers, [first_user_worker, second_user_worker])
  end

  context "for an admin" do
    before { enable_can(view, first_user_admin) }

    it "renders new user links" do
      render

      User::VALID_EMPLOYEE_TYPES.each do |employee_type|
        path = new_user_path(employee_type: employee_type)
        expect(rendered).to have_link(nil, href: path)
      end
    end

    it "renders a list of user/admins" do
      render

      assert_select "#user-#{first_user_admin.id}"
      first_url = user_path(first_user_admin)
      assert_select "a[data-method=\"delete\"][href='#{first_url}']", count: 0
      expect(rendered).to have_link(nil, href: edit_user_path(first_user_admin))
      expect(rendered).to have_link(nil, href: first_url)

      assert_select "#user-#{second_user_admin.id}"
      second_url = user_path(second_user_admin)
      assert_select "a[data-method=\"delete\"][href='#{second_url}']"
      expect(rendered).to have_link(nil, href: second_url)
      expect(rendered)
        .to have_link(nil, href: edit_user_path(second_user_admin))
    end

    it "renders a list of user/reporters" do
      render

      [first_user_reporter, second_user_reporter].each do |reporter|
        assert_select "#user-#{reporter.id}"
        assert_select "#user-#{reporter.id} a[data-method=\"delete\"]"
        expect(rendered).to have_link(nil, href: user_path(reporter))
        expect(rendered).to have_link(nil, href: edit_user_path(reporter))
      end
    end

    it "renders a list of user/reviewers" do
      render

      [first_user_reviewer, second_user_reviewer].each do |reviewer|
        assert_select "#user-#{reviewer.id}"
        assert_select "#user-#{reviewer.id} a[data-method=\"delete\"]"
        expect(rendered).to have_link(nil, href: user_path(reviewer))
        expect(rendered).to have_link(nil, href: edit_user_path(reviewer))
      end
    end

    it "renders a list of user/workers" do
      render

      [first_user_worker, second_user_worker].each do |worker|
        assert_select "#user-#{worker.id}"
        assert_select "#user-#{worker.id} a[data-method=\"delete\"]"
        expect(rendered).to have_link(nil, href: user_path(worker))
        expect(rendered).to have_link(nil, href: edit_user_path(worker))
      end
    end
  end

  context "for a reviewer" do
    before { enable_can(view, first_user_reviewer) }

    it "doesn't render new user links" do
      render

      User::VALID_EMPLOYEE_TYPES.each do |employee_type|
        path = new_user_path(employee_type: employee_type)
        expect(rendered).not_to have_link(nil, href: path)
      end
    end

    it "renders a list of user/admins" do
      render

      [first_user_admin, second_user_admin].each do |admin|
        assert_select "#user-#{admin.id}"
        assert_select "#user-#{admin.id} a[data-method=\"delete\"]", count: 0
        expect(rendered).to have_link(nil, href: user_path(admin))
        expect(rendered).not_to have_link(nil, href: edit_user_path(admin))
      end
    end

    it "renders a list of user/reporters" do
      render

      [first_user_reporter, second_user_reporter].each do |reporter|
        assert_select "#user-#{reporter.id}"
        assert_select "#user-#{reporter.id} a[data-method=\"delete\"]", count: 0
        expect(rendered).to have_link(nil, href: user_path(reporter))
        expect(rendered).not_to have_link(nil, href: edit_user_path(reporter))
      end
    end

    it "renders a list of user/reviewers" do
      render

      [first_user_reviewer, second_user_reviewer].each do |reviewer|
        assert_select "#user-#{reviewer.id}"
        assert_select "#user-#{reviewer.id} a[data-method=\"delete\"]", count: 0
        expect(rendered).to have_link(nil, href: user_path(reviewer))
      end

      expect(rendered)
        .to have_link(nil, href: edit_user_path(first_user_reviewer))
      expect(rendered)
        .not_to have_link(nil, href: edit_user_path(second_user_reviewer))
    end

    it "renders a list of user/workers" do
      render

      [first_user_worker, second_user_worker].each do |worker|
        assert_select "#user-#{worker.id}"
        assert_select "#user-#{worker.id} a[data-method=\"delete\"]", count: 0
        expect(rendered).to have_link(nil, href: user_path(worker))
        expect(rendered).not_to have_link(nil, href: edit_user_path(worker))
      end
    end
  end

  context "for a reporter" do
    before { enable_can(view, first_user_reporter) }

    it "doesn't render new user links" do
      render

      User::VALID_EMPLOYEE_TYPES.each do |employee_type|
        path = new_user_path(employee_type: employee_type)
        expect(rendered).not_to have_link(nil, href: path)
      end
    end

    it "renders a list of user/admins" do
      render

      [first_user_admin, second_user_admin].each do |admin|
        assert_select "#user-#{admin.id}"
        assert_select "#user-#{admin.id} a[data-method=\"delete\"]", count: 0
        expect(rendered).to have_link(nil, href: user_path(admin))
        expect(rendered).not_to have_link(nil, href: edit_user_path(admin))
      end
    end

    it "renders a list of user/reporters" do
      render

      [first_user_reporter, second_user_reporter].each do |reporter|
        assert_select "#user-#{reporter.id}"
        assert_select "#user-#{reporter.id} a[data-method=\"delete\"]", count: 0
        expect(rendered).to have_link(nil, href: user_path(reporter))
      end

      expect(rendered)
        .to have_link(nil, href: edit_user_path(first_user_reporter))
      expect(rendered)
        .not_to have_link(nil, href: edit_user_path(second_user_reporter))
    end

    it "renders a list of user/reviewers" do
      render

      [first_user_reviewer, second_user_reviewer].each do |reviewer|
        assert_select "#user-#{reviewer.id}"
        assert_select "#user-#{reviewer.id} a[data-method=\"delete\"]", count: 0
        expect(rendered).to have_link(nil, href: user_path(reviewer))
        expect(rendered).not_to have_link(nil, href: edit_user_path(reviewer))
      end
    end

    it "renders a list of user/workers" do
      render

      [first_user_worker, second_user_worker].each do |worker|
        assert_select "#user-#{worker.id}"
        assert_select "#user-#{worker.id} a[data-method=\"delete\"]", count: 0
        expect(rendered).to have_link(nil, href: user_path(worker))
        expect(rendered).not_to have_link(nil, href: edit_user_path(worker))
      end
    end
  end

  context "for a worker" do
    before { enable_can(view, first_user_worker) }

    it "doesn't render new user links" do
      render

      User::VALID_EMPLOYEE_TYPES.each do |employee_type|
        path = new_user_path(employee_type: employee_type)
        expect(rendered).not_to have_link(nil, href: path)
      end
    end

    it "renders a list of user/admins" do
      render

      [first_user_admin, second_user_admin].each do |admin|
        assert_select "#user-#{admin.id}"
        assert_select "#user-#{admin.id} a[data-method=\"delete\"]", count: 0
        expect(rendered).to have_link(nil, href: user_path(admin))
        expect(rendered).not_to have_link(nil, href: edit_user_path(admin))
      end
    end

    it "renders a list of user/reporters" do
      render

      [first_user_reporter, second_user_reporter].each do |reporter|
        assert_select "#user-#{reporter.id}"
        assert_select "#user-#{reporter.id} a[data-method=\"delete\"]", count: 0
        expect(rendered).to have_link(nil, href: user_path(reporter))
        expect(rendered).not_to have_link(nil, href: edit_user_path(reporter))
      end
    end

    it "renders a list of user/reviewers" do
      render

      [first_user_reviewer, second_user_reviewer].each do |reviewer|
        assert_select "#user-#{reviewer.id}"
        assert_select "#user-#{reviewer.id} a[data-method=\"delete\"]", count: 0
        expect(rendered).to have_link(nil, href: user_path(reviewer))
        expect(rendered).not_to have_link(nil, href: edit_user_path(reviewer))
      end
    end

    it "renders a list of user/workers" do
      render

      [first_user_worker, second_user_worker].each do |worker|
        assert_select "#user-#{worker.id}"
        assert_select "#user-#{worker.id} a[data-method=\"delete\"]", count: 0
        expect(rendered).to have_link(nil, href: user_path(worker))
      end

      expect(rendered)
        .to have_link(nil, href: edit_user_path(first_user_worker))
      expect(rendered)
        .not_to have_link(nil, href: edit_user_path(second_user_worker))
    end
  end
end
