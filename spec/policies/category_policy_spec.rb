# frozen_string_literal: true

require "rails_helper"

RSpec.describe CategoryPolicy, type: :policy do
  let(:admin) { Fabricate(:user_admin) }
  let(:category) { Fabricate(:category) }

  subject { described_class }

  permissions :index?, :show? do
    %i[admin reviewer worker reporter].each do |employee_type|
      it "permits #{employee_type}" do
        user = Fabricate("user_#{employee_type}")
        expect(subject).to permit(user, category)
      end
    end

    it "blocks non-employees" do
      user = Fabricate(:user)
      user.employee.destroy
      expect(subject).not_to permit(user, category)
    end
  end

  permissions :create?, :new? do
    it "permits admins" do
      expect(subject).to permit(admin, category)
    end

    %i[reviewer worker reporter].each do |employee_type|
      it "blocks #{employee_type}" do
        user = Fabricate("user_#{employee_type}")
        expect(subject).not_to permit(user, category)
      end
    end

    it "blocks non-employees" do
      user = Fabricate(:user)
      user.employee.destroy
      expect(subject).not_to permit(user, category)
    end
  end

  permissions :update?, :edit? do
    %i[admin reviewer].each do |employee_type|
      it "permits #{employee_type}" do
        user = Fabricate("user_#{employee_type}")
        expect(subject).to permit(user, category)
      end
    end

    %i[worker reporter].each do |employee_type|
      it "blocks #{employee_type}" do
        user = Fabricate("user_#{employee_type}")
        expect(subject).not_to permit(user, category)
      end
    end

    it "blocks non-employees" do
      user = Fabricate(:user)
      user.employee.destroy
      expect(subject).not_to permit(user, category)
    end
  end

  permissions :destroy? do
    it "permits admins" do
      expect(subject).to permit(admin, category)
    end

    %i[reviewer worker reporter].each do |employee_type|
      it "blocks #{employee_type}" do
        user = Fabricate("user_#{employee_type}")
        expect(subject).not_to permit(user, category)
      end
    end

    it "blocks non-employees" do
      user = Fabricate(:user)
      user.employee.destroy
      expect(subject).not_to permit(user, category)
    end
  end
end
