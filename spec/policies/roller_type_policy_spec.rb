# frozen_string_literal: true

require "rails_helper"

RSpec.describe RollerTypePolicy, type: :policy do
  let(:admin) { Fabricate(:user_admin) }
  let(:issue_type) { Fabricate(:issue_type) }

  subject { described_class }

  permissions :index?, :show? do
    it "permits admins" do
      expect(subject).to permit(admin, issue_type)
    end

    %i[reviewer worker reporter].each do |employee_type|
      it "blocks #{employee_type}" do
        user = Fabricate("user_#{employee_type}")
        expect(subject).not_to permit(user, issue_type)
      end
    end

    it "blocks non-employees" do
      user = Fabricate(:user)
      user.employee_type = nil
      expect(subject).not_to permit(user, issue_type)
    end
  end

  permissions :create?, :new?, :update?, :edit?, :destroy? do
    it "permits admins" do
      expect(subject).to permit(admin, issue_type)
    end

    %i[reviewer worker reporter].each do |employee_type|
      it "blocks #{employee_type}" do
        user = Fabricate("user_#{employee_type}")
        expect(subject).not_to permit(user, issue_type)
      end
    end

    it "blocks non-employees" do
      user = Fabricate(:user)
      user.employee_type = nil
      expect(subject).not_to permit(user, issue_type)
    end
  end
end
