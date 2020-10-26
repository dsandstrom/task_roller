# frozen_string_literal: true

require "rails_helper"

RSpec.describe TaskSubscriptionPolicy, type: :policy do
  subject { described_class }

  permissions :index?, :new?, :create? do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      it "permits #{employee_type}" do
        user = Fabricate("user_#{employee_type.downcase}")
        expect(subject).to permit(user)
      end
    end

    it "blocks non-employees" do
      user = Fabricate(:user)
      user.employee_type = nil
      expect(subject).not_to permit(user)
    end
  end

  permissions :show?, :edit?, :update?, :destroy? do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "when belongs to them" do
        it "permits #{employee_type}" do
          user = Fabricate("user_#{employee_type.downcase}")
          task_subscription = Fabricate(:task_subscription, user: user)
          expect(subject).to permit(user, task_subscription)
        end
      end

      context "when doesn't belong to them" do
        it "permits #{employee_type}" do
          user = Fabricate("user_#{employee_type.downcase}")
          task_subscription = Fabricate(:task_subscription)
          expect(subject).not_to permit(user, task_subscription)
        end
      end
    end

    it "blocks non-employees" do
      user = Fabricate(:user)
      task_subscription = Fabricate(:task_subscription, user: user)
      user.employee_type = nil
      expect(subject).not_to permit(user, task_subscription)
    end
  end
end
