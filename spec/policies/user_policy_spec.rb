# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserPolicy, type: :policy do
  let(:admin) { Fabricate(:user_admin) }
  let(:record) { Fabricate(:user_reviewer) }

  subject { described_class }

  permissions :index?, :show? do
    %i[admin reviewer worker reporter].each do |employee_type|
      it "permits #{employee_type}" do
        user = Fabricate("user_#{employee_type}")
        expect(subject).to permit(user, record)
      end
    end

    it "blocks non-employees" do
      user = Fabricate(:user)
      user.employee.destroy
      expect(subject).not_to permit(user, record)
    end
  end

  permissions :create?, :new? do
    it "permits admins" do
      expect(subject).to permit(admin, record)
    end

    it "blocks the current user" do
      expect(subject).not_to permit(record, record)
    end

    %i[reviewer worker reporter].each do |employee_type|
      it "blocks #{employee_type}" do
        user = Fabricate("user_#{employee_type}")
        expect(subject).not_to permit(user, record)
      end
    end

    it "blocks non-employees" do
      user = Fabricate(:user)
      user.employee.destroy
      expect(subject).not_to permit(user, record)
    end
  end

  permissions :update?, :edit? do
    it "permits admins" do
      expect(subject).to permit(admin, record)
    end

    it "permits the current user" do
      expect(subject).to permit(record, record)
    end

    %i[reviewer worker reporter].each do |employee_type|
      it "blocks #{employee_type}" do
        user = Fabricate("user_#{employee_type}")
        expect(subject).not_to permit(user, record)
      end
    end

    it "blocks non-employees" do
      user = Fabricate(:user)
      user.employee.destroy
      expect(subject).not_to permit(user, record)
    end
  end

  permissions :destroy? do
    it "permits admins" do
      expect(subject).to permit(admin, record)
    end

    it "blocks the current user" do
      expect(subject).not_to permit(record, record)
    end

    %i[reviewer worker reporter].each do |employee_type|
      it "blocks #{employee_type}" do
        user = Fabricate("user_#{employee_type}")
        expect(subject).not_to permit(user, record)
      end
    end

    it "blocks non-employees" do
      user = Fabricate(:user)
      user.employee.destroy
      expect(subject).not_to permit(user, record)
    end
  end
end
