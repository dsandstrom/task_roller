# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProgressionPolicy, type: :policy do
  let(:admin) { Fabricate(:user_admin) }
  let(:task) { Fabricate(:task) }
  let(:progression) { Fabricate(:progression, task: task) }

  subject { described_class }

  permissions :index?, :show? do
    it "permits admins" do
      expect(subject).to permit(admin, progression)
    end

    %i[reviewer worker reporter].each do |employee_comment|
      it "permits #{employee_comment}" do
        user = Fabricate("user_#{employee_comment}")
        expect(subject).to permit(user, progression)
      end
    end

    it "blocks non-employees" do
      user = Fabricate(:user)
      user.employee_type = nil
      expect(subject).not_to permit(user, progression)
    end
  end

  permissions :new?, :create? do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        context "when the task is assigned to them" do
          before do
            task.assignees << current_user
          end

          it "permits them" do
            expect(subject).to permit(current_user, progression)
          end
        end

        context "when the task is not assigned to them" do
          it "blocks them" do
            expect(subject).not_to permit(current_user)
          end
        end
      end
    end

    it "blocks non-employees" do
      user = Fabricate(:user)
      task.assignees << user
      user.employee_type = nil
      expect(subject).not_to permit(user, progression)
    end
  end

  permissions :edit?, :update?, :destroy? do
    %i[admin].each do |employee_type|
      it "permits #{employee_type}" do
        user = Fabricate("user_#{employee_type}")
        expect(subject).to permit(user, progression)
      end
    end

    %i[reviewer worker reporter].each do |employee_type|
      it "blocks #{employee_type}" do
        user = Fabricate("user_#{employee_type}")
        expect(subject).not_to permit(user, progression)
      end
    end

    it "blocks non-employees" do
      user = Fabricate(:user)
      user.employee_type = nil
      expect(subject).not_to permit(user, progression)
    end
  end

  permissions :finish? do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        context "when the progression belongs to them" do
          before do
            progression.user = current_user
          end

          it "permits them" do
            expect(subject).to permit(current_user, progression)
          end
        end

        context "when the progression is not assigned" do
          before { progression.user = nil }

          it "blocks them" do
            expect(subject).not_to permit(current_user)
          end
        end

        context "when the progression is assigned to someone else" do
          before do
            user = Fabricate(:user_worker)
            task.assignees << user
            progression.user = user
          end

          it "blocks them" do
            expect(subject).not_to permit(current_user)
          end
        end
      end
    end

    it "blocks non-employees" do
      user = Fabricate(:user)
      progression.user = user
      user.employee_type = nil
      expect(subject).not_to permit(user, progression)
    end
  end
end
