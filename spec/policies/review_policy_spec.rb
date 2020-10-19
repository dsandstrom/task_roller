# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReviewPolicy, type: :policy do
  let(:admin) { Fabricate(:user_admin) }
  let(:task) { Fabricate(:task) }
  let(:review) { Fabricate(:review, task: task) }

  subject { described_class }

  permissions :index?, :show? do
    it "permits admins" do
      expect(subject).to permit(admin, review)
    end

    %i[reviewer worker reporter].each do |employee_comment|
      it "permits #{employee_comment}" do
        user = Fabricate("user_#{employee_comment}")
        expect(subject).to permit(user, review)
      end
    end

    it "blocks non-employees" do
      user = Fabricate(:user)
      user.employee_type = nil
      expect(subject).not_to permit(user, review)
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
            expect(subject).to permit(current_user, review)
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
      expect(subject).not_to permit(user, review)
    end
  end

  permissions :destroy? do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        context "when task is open, review pending, and belongs to them" do
          let(:task) { Fabricate(:open_task) }
          let(:review) do
            Fabricate(:pending_review, task: task, user: current_user)
          end

          it "permits them" do
            expect(subject).to permit(current_user, review)
          end
        end

        context "when task is closed" do
          let(:task) { Fabricate(:closed_task) }
          let(:review) do
            Fabricate(:pending_review, task: task, user: current_user)
          end

          it "blocks them" do
            expect(subject).not_to permit(current_user, review)
          end
        end

        context "when review is approved" do
          let(:task) { Fabricate(:open_task) }
          let(:review) do
            Fabricate(:approved_review, task: task, user: current_user)
          end

          it "blocks them" do
            expect(subject).not_to permit(current_user, review)
          end
        end

        context "when review is disapproved" do
          let(:task) { Fabricate(:open_task) }
          let(:review) do
            Fabricate(:disapproved_review, task: task, user: current_user)
          end

          it "blocks them" do
            expect(subject).not_to permit(current_user, review)
          end
        end

        context "when review belongs to someone else" do
          let(:task) { Fabricate(:open_task) }
          let(:review) { Fabricate(:pending_review, task: task) }

          it "blocks them" do
            expect(subject).not_to permit(current_user, review)
          end
        end
      end
    end

    it "blocks non-employees" do
      user = Fabricate(:user)
      user.employee_type = nil
      expect(subject).not_to permit(user)
    end
  end

  permissions :edit?, :update? do
    %i[admin].each do |employee_type|
      it "permits #{employee_type}" do
        user = Fabricate("user_#{employee_type}")
        expect(subject).to permit(user, review)
      end
    end

    %i[reviewer worker reporter].each do |employee_type|
      it "blocks #{employee_type}" do
        user = Fabricate("user_#{employee_type}")
        expect(subject).not_to permit(user, review)
      end
    end

    it "blocks non-employees" do
      user = Fabricate(:user)
      user.employee_type = nil
      expect(subject).not_to permit(user, review)
    end
  end

  permissions :approve?, :disapprove? do
    %i[admin reviewer].each do |employee_type|
      it "permits #{employee_type}" do
        user = Fabricate("user_#{employee_type}")
        expect(subject).to permit(user, review)
      end
    end

    %i[worker reporter].each do |employee_type|
      it "blocks #{employee_type}" do
        user = Fabricate("user_#{employee_type}")
        expect(subject).not_to permit(user, review)
      end
    end

    it "blocks non-employees" do
      user = Fabricate(:user)
      user.employee_type = nil
      expect(subject).not_to permit(user, review)
    end
  end
end
