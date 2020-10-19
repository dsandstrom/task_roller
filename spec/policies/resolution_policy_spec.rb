# frozen_string_literal: true

require "rails_helper"

RSpec.describe ResolutionPolicy, type: :policy do
  let(:admin) { Fabricate(:user_admin) }

  subject { described_class }

  permissions :index?, :show? do
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

  permissions :new?, :create?, :approve?, :disapprove? do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

      context "when their issue" do
        it "permits #{employee_type}" do
          issue = Fabricate(:issue, user: current_user)
          resolution = Fabricate(:resolution, issue: issue)
          expect(subject).to permit(current_user, resolution)
        end
      end

      context "when someone else's issue" do
        it "blocks #{employee_type}" do
          resolution = Fabricate(:resolution)
          expect(subject).not_to permit(current_user, resolution)
        end
      end
    end

    it "blocks non-employees" do
      user = Fabricate(:user)
      issue = Fabricate(:issue, user: user)
      resolution = Fabricate(:resolution, issue: issue, user: user)
      user.employee_type = nil
      expect(subject).not_to permit(user, resolution)
    end
  end

  permissions :destroy? do
    it "permits admins" do
      resolution = Fabricate(:resolution)
      expect(subject).to permit(admin, resolution)
    end

    %i[reviewer worker reporter].each do |employee_type|
      it "blocks #{employee_type}" do
        user = Fabricate("user_#{employee_type}")
        resolution = Fabricate(:resolution, user: user)
        expect(subject).not_to permit(user, resolution)
      end
    end

    it "blocks non-employees" do
      user = Fabricate(:user)
      issue = Fabricate(:issue, user: user)
      resolution = Fabricate(:resolution, issue: issue, user: user)
      user.employee_type = nil
      expect(subject).not_to permit(user, resolution)
    end
  end
end
