# frozen_string_literal: true

require "rails_helper"

RSpec.describe IssueSubscriptionPolicy, type: :policy do
  subject { described_class }

  permissions :destroy? do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "when belongs to them" do
        it "permits #{employee_type}" do
          user = Fabricate("user_#{employee_type.downcase}")
          subscription = Fabricate(:issue_subscription, user: user)
          expect(subject).to permit(user, subscription)
        end
      end

      context "when doesn't belong to them" do
        it "permits #{employee_type}" do
          user = Fabricate("user_#{employee_type.downcase}")
          subscription = Fabricate(:issue_subscription)
          expect(subject).not_to permit(user, subscription)
        end
      end
    end

    it "blocks non-employees" do
      user = Fabricate(:user)
      subscription = Fabricate(:issue_subscription, user: user)
      user.employee_type = nil
      expect(subject).not_to permit(user, subscription)
    end
  end
end
