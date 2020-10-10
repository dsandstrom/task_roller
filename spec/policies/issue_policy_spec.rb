# frozen_string_literal: true

require "rails_helper"

RSpec.describe IssuePolicy, type: :policy do
  let(:admin) { Fabricate(:user_admin) }
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }

  subject { described_class }

  permissions :index?, :show? do
    let(:issue) { Fabricate(:issue, project: project) }

    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      it "permits #{employee_type}" do
        user = Fabricate("user_#{employee_type.downcase}")
        expect(subject).to permit(user, issue)
      end
    end

    it "blocks non-employees" do
      user = Fabricate(:user)
      user.employee.destroy
      expect(subject).not_to permit(user, issue)
    end
  end

  permissions :create?, :new? do
    let(:issue) { Fabricate(:issue, project: project) }

    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      it "permits #{employee_type}" do
        user = Fabricate("user_#{employee_type.downcase}")
        expect(subject).to permit(user, issue)
      end
    end

    it "blocks non-employees" do
      user = Fabricate(:user)
      user.employee.destroy
      expect(subject).not_to permit(user, issue)
    end
  end

  permissions :update?, :edit? do
    context "for an admin" do
      context "when someone else's issue" do
        let(:issue) { Fabricate(:issue, project: project) }

        it "permits them" do
          expect(subject).to permit(admin, issue)
        end
      end

      context "when their own issue" do
        let(:issue) { Fabricate(:issue, project: project, user: admin) }

        it "permits them" do
          expect(subject).to permit(admin, issue)
        end
      end
    end

    %i[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:user) { Fabricate("user_#{employee_type}") }

        context "when someone else's issue" do
          let(:issue) { Fabricate(:issue, project: project) }

          it "doesn't permit them" do
            expect(subject).not_to permit(user, issue)
          end
        end

        context "when their own issue" do
          let(:issue) { Fabricate(:issue, project: project, user: user) }

          it "permits them" do
            expect(subject).to permit(user, issue)
          end
        end
      end
    end
  end

  permissions :destroy? do
    context "for an admin" do
      context "when someone else's issue" do
        let(:issue) { Fabricate(:issue, project: project) }

        it "permits them" do
          expect(subject).to permit(admin, issue)
        end
      end

      context "when their own issue" do
        let(:issue) { Fabricate(:issue, project: project, user: admin) }

        it "permits them" do
          expect(subject).to permit(admin, issue)
        end
      end
    end

    %i[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:user) { Fabricate("user_#{employee_type}") }

        context "when someone else's issue" do
          let(:issue) { Fabricate(:issue, project: project) }

          it "doesn't permit them" do
            expect(subject).not_to permit(user, issue)
          end
        end

        context "when their own issue" do
          let(:issue) { Fabricate(:issue, project: project, user: user) }

          it "doesn't permit them" do
            expect(subject).not_to permit(user, issue)
          end
        end
      end
    end
  end
end
