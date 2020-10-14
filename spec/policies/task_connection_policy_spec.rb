# frozen_string_literal: true

require "rails_helper"

RSpec.describe TaskConnectionPolicy, type: :policy do
  subject { described_class }

  permissions :index?, :show? do
    %i[admin reviewer worker reporter].each do |employee_type|
      it "permits #{employee_type}" do
        user = Fabricate("user_#{employee_type}")
        expect(subject).to permit(user)
      end
    end

    it "blocks non-employees" do
      user = Fabricate(:user)
      user.employee_type = nil
      expect(subject).not_to permit(user)
    end
  end

  permissions :create?, :new?, :edit?, :update?, :destroy? do
    %i[admin reviewer].each do |employee_type|
      it "permits #{employee_type}" do
        user = Fabricate("user_#{employee_type}")
        expect(subject).to permit(user)
      end
    end

    %i[worker reporter].each do |employee_type|
      it "blocks #{employee_type}" do
        user = Fabricate("user_#{employee_type}")
        expect(subject).not_to permit(user)
      end
    end

    it "blocks non-employees" do
      user = Fabricate(:user)
      user.employee_type = nil
      expect(subject).not_to permit(user)
    end
  end
end
