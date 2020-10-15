# frozen_string_literal: true

require "rails_helper"

RSpec.describe TaskPolicy, type: :policy do
  let(:admin) { Fabricate(:user_admin) }
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }

  subject { described_class }

  permissions :index?, :show? do
    let(:task) { Fabricate(:task, project: project) }

    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      it "permits #{employee_type}" do
        user = Fabricate("user_#{employee_type.downcase}")
        expect(subject).to permit(user, task)
      end
    end

    it "blocks non-employees" do
      user = Fabricate(:user)
      user.employee_type = nil
      expect(subject).not_to permit(user, task)
    end
  end

  permissions :create?, :new? do
    let(:task) { Fabricate(:task, project: project) }

    %i[admin reviewer].each do |employee_type|
      it "permits #{employee_type}" do
        user = Fabricate("user_#{employee_type.downcase}")
        expect(subject).to permit(user, task)
      end
    end

    %i[worker reporter].each do |employee_type|
      it "blocks #{employee_type}" do
        user = Fabricate("user_#{employee_type.downcase}")
        expect(subject).not_to permit(user, task)
      end
    end

    it "blocks non-employees" do
      user = Fabricate(:user)
      user.employee_type = nil
      expect(subject).not_to permit(user, task)
    end
  end

  permissions :update?, :edit? do
    context "for an admin" do
      context "when someone else's task" do
        let(:task) { Fabricate(:task, project: project) }

        it "permits them" do
          expect(subject).to permit(admin, task)
        end
      end

      context "when their own task" do
        let(:task) { Fabricate(:task, project: project, user: admin) }

        it "permits them" do
          expect(subject).to permit(admin, task)
        end
      end
    end

    %i[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:user) { Fabricate("user_#{employee_type}") }

        context "when someone else's task" do
          let(:task) { Fabricate(:task, project: project) }

          it "doesn't permit them" do
            expect(subject).not_to permit(user, task)
          end
        end

        context "when their own task" do
          let(:task) { Fabricate(:task, project: project, user: user) }

          it "permits them" do
            expect(subject).to permit(user, task)
          end
        end
      end
    end
  end

  permissions :destroy?, :open?, :close? do
    context "for an admin" do
      context "when someone else's task" do
        let(:task) { Fabricate(:task, project: project) }

        it "permits them" do
          expect(subject).to permit(admin, task)
        end
      end

      context "when their own task" do
        let(:task) { Fabricate(:task, project: project, user: admin) }

        it "permits them" do
          expect(subject).to permit(admin, task)
        end
      end
    end

    %i[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:user) { Fabricate("user_#{employee_type}") }

        context "when someone else's task" do
          let(:task) { Fabricate(:task, project: project) }

          it "doesn't permit them" do
            expect(subject).not_to permit(user, task)
          end
        end

        context "when their own task" do
          let(:task) { Fabricate(:task, project: project, user: user) }

          it "doesn't permit them" do
            expect(subject).not_to permit(user, task)
          end
        end
      end
    end
  end
end
