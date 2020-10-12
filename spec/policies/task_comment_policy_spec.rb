# frozen_string_literal: true

require "rails_helper"

RSpec.describe TaskCommentPolicy, type: :policy do
  let(:admin) { Fabricate(:user_admin) }

  subject { described_class }

  permissions :index?, :show? do
    let(:task_comment) { Fabricate(:task_comment) }

    it "permits admins" do
      expect(subject).to permit(admin, task_comment)
    end

    %i[reviewer worker reporter].each do |employee_comment|
      it "permits #{employee_comment}" do
        user = Fabricate("user_#{employee_comment}")
        expect(subject).to permit(user, task_comment)
      end
    end

    it "blocks non-employees" do
      user = Fabricate(:user)
      user.employee_type = nil
      expect(subject).not_to permit(user, task_comment)
    end
  end

  permissions :create?, :new? do
    let(:task_comment) { Fabricate(:task_comment) }

    %i[admin reviewer worker reporter].each do |employee_comment|
      it "permits #{employee_comment}" do
        user = Fabricate("user_#{employee_comment}")
        expect(subject).to permit(user, task_comment)
      end
    end

    it "blocks non-employees" do
      user = Fabricate(:user)
      user.employee_type = nil
      expect(subject).not_to permit(user, task_comment)
    end
  end

  permissions :update?, :edit? do
    let(:task_comment) { Fabricate(:task_comment) }

    context "for an admin" do
      context "when their IssueComment" do
        it "permits them" do
          task_comment = Fabricate(:task_comment, user: admin)
          expect(subject).to permit(admin, task_comment)
        end
      end

      context "when someone else's IssueComment" do
        it "permits them" do
          task_comment = Fabricate(:task_comment)
          expect(subject).to permit(admin, task_comment)
        end
      end
    end

    %i[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        context "when their IssueComment" do
          it "permits them" do
            task_comment = Fabricate(:task_comment, user: current_user)
            expect(subject).to permit(current_user, task_comment)
          end
        end

        context "when someone else's IssueComment" do
          it "blocks them" do
            task_comment = Fabricate(:task_comment)
            expect(subject).not_to permit(current_user, task_comment)
          end
        end
      end
    end

    it "blocks non-employees" do
      user = Fabricate(:user)
      task_comment = Fabricate(:task_comment, user: user)
      user.employee_type = nil
      expect(subject).not_to permit(user, task_comment)
    end
  end

  permissions :destroy? do
    it "permits admins" do
      task_comment = Fabricate(:task_comment)
      expect(subject).to permit(admin, task_comment)
    end

    %i[reviewer worker reporter].each do |employee_comment|
      it "blocks #{employee_comment}" do
        user = Fabricate("user_#{employee_comment}")
        task_comment = Fabricate(:task_comment, user: user)
        expect(subject).not_to permit(user, task_comment)
      end
    end

    it "blocks non-employees" do
      user = Fabricate(:user)
      task_comment = Fabricate(:task_comment, user: user)
      user.employee_type = nil
      expect(subject).not_to permit(user, task_comment)
    end
  end
end
