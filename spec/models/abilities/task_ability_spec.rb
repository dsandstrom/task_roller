# frozen_string_literal: true

require "rails_helper"
require "cancan/matchers"

RSpec.describe Ability do
  describe "Progression model" do
    let(:task) { Fabricate(:task) }

    describe "for an admin" do
      let(:admin) { Fabricate(:user_admin) }
      subject(:ability) { Ability.new(admin) }

      context "for a totally visible task" do
        let(:project) { Fabricate(:project) }
        let(:task) { Fabricate(:task, project: project) }

        context "when assigned to the task" do
          let(:progression) { Fabricate(:progression, task: task, user: admin) }

          before { task.assignees << admin }

          it { is_expected.to be_able_to(:create, progression) }
        end

        context "when not assigned to the task" do
          let(:progression) { Fabricate(:progression, task: task, user: admin) }

          it { is_expected.not_to be_able_to(:create, progression) }
        end

        context "when belongs to them" do
          let(:progression) { Fabricate(:progression, task: task, user: admin) }

          it { is_expected.to be_able_to(:read, progression) }
          it { is_expected.to be_able_to(:update, progression) }
          it { is_expected.to be_able_to(:destroy, progression) }
          it { is_expected.to be_able_to(:finish, progression) }
        end

        context "when doesn't belong to them" do
          let(:progression) { Fabricate(:progression, task: task) }

          it { is_expected.to be_able_to(:read, progression) }
          it { is_expected.to be_able_to(:update, progression) }
          it { is_expected.to be_able_to(:destroy, progression) }
          it { is_expected.not_to be_able_to(:finish, progression) }
        end
      end

      context "for a task from an internal project" do
        let(:project) { Fabricate(:internal_project) }
        let(:task) { Fabricate(:task, project: project) }

        context "when assigned to the task" do
          let(:progression) { Fabricate(:progression, task: task, user: admin) }

          before { task.assignees << admin }

          it { is_expected.to be_able_to(:create, progression) }
        end

        context "when not assigned to the task" do
          let(:progression) { Fabricate(:progression, task: task, user: admin) }

          it { is_expected.not_to be_able_to(:create, progression) }
        end

        context "when belongs to them" do
          let(:progression) { Fabricate(:progression, task: task, user: admin) }

          it { is_expected.to be_able_to(:read, progression) }
          it { is_expected.to be_able_to(:update, progression) }
          it { is_expected.to be_able_to(:destroy, progression) }
          it { is_expected.to be_able_to(:finish, progression) }
        end

        context "when doesn't belong to them" do
          let(:progression) { Fabricate(:progression, task: task) }

          it { is_expected.to be_able_to(:read, progression) }
          it { is_expected.to be_able_to(:update, progression) }
          it { is_expected.to be_able_to(:destroy, progression) }
          it { is_expected.not_to be_able_to(:finish, progression) }
        end
      end

      context "for a task from an invisible project" do
        let(:project) { Fabricate(:invisible_project) }
        let(:task) { Fabricate(:task, project: project) }

        context "when assigned to the task" do
          let(:progression) { Fabricate(:progression, task: task, user: admin) }

          before { task.assignees << admin }

          it { is_expected.to be_able_to(:create, progression) }
        end

        context "when not assigned to the task" do
          let(:progression) { Fabricate(:progression, task: task, user: admin) }

          it { is_expected.not_to be_able_to(:create, progression) }
        end

        context "when belongs to them" do
          let(:progression) { Fabricate(:progression, task: task, user: admin) }

          it { is_expected.to be_able_to(:read, progression) }
          it { is_expected.to be_able_to(:update, progression) }
          it { is_expected.to be_able_to(:destroy, progression) }
          it { is_expected.to be_able_to(:finish, progression) }
        end

        context "when doesn't belong to them" do
          let(:progression) { Fabricate(:progression, task: task) }

          it { is_expected.to be_able_to(:read, progression) }
          it { is_expected.to be_able_to(:update, progression) }
          it { is_expected.to be_able_to(:destroy, progression) }
          it { is_expected.not_to be_able_to(:finish, progression) }
        end
      end

      context "and task is closed" do
        let(:project) { Fabricate(:project) }
        let(:task) { Fabricate(:closed_task, project: project) }

        context "when assigned to the task" do
          let(:progression) { Fabricate(:progression, task: task, user: admin) }

          before { task.assignees << admin }

          it { is_expected.to be_able_to(:create, progression) }
        end

        context "when belongs to them" do
          let(:progression) { Fabricate(:progression, task: task, user: admin) }

          it { is_expected.to be_able_to(:read, progression) }
          it { is_expected.to be_able_to(:update, progression) }
          it { is_expected.to be_able_to(:destroy, progression) }
          it { is_expected.to be_able_to(:finish, progression) }
        end
      end

      context "when no task" do
        let(:progression) { Fabricate(:progression, task: task, user: admin) }

        before do
          task.assignees << admin
          progression.update_attribute :task_id, 0
        end

        it { is_expected.not_to be_able_to(:create, progression) }
      end
    end

    %i[reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        context "for a totally visible task" do
          let(:project) { Fabricate(:project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when assigned to the task" do
            let(:progression) do
              Fabricate(:progression, task: task, user: current_user)
            end

            before { task.assignees << current_user }

            it { is_expected.to be_able_to(:create, progression) }
          end

          context "when not assigned to the task" do
            let(:progression) do
              Fabricate(:progression, task: task, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, progression) }
          end

          context "when belongs to them" do
            let(:progression) do
              Fabricate(:progression, task: task, user: current_user)
            end

            it { is_expected.to be_able_to(:read, progression) }
            it { is_expected.not_to be_able_to(:update, progression) }
            it { is_expected.to be_able_to(:finish, progression) }
            it { is_expected.not_to be_able_to(:destroy, progression) }
          end

          context "when doesn't belong to them" do
            let(:progression) { Fabricate(:progression, task: task) }

            it { is_expected.to be_able_to(:read, progression) }
            it { is_expected.not_to be_able_to(:update, progression) }
            it { is_expected.not_to be_able_to(:finish, progression) }
            it { is_expected.not_to be_able_to(:destroy, progression) }
          end

          context "when no task" do
            let(:progression) do
              Fabricate(:progression, task: task, user: current_user)
            end

            before do
              task.assignees << current_user
              progression.update_attribute :task_id, 0
            end

            it { is_expected.not_to be_able_to(:create, progression) }
          end
        end

        context "for a task from an internal project" do
          let(:project) { Fabricate(:internal_project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when assigned to the task" do
            let(:progression) do
              Fabricate(:progression, task: task, user: current_user)
            end

            before { task.assignees << current_user }

            it { is_expected.to be_able_to(:create, progression) }
          end

          context "when not assigned to the task" do
            let(:progression) do
              Fabricate(:progression, task: task, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, progression) }
          end

          context "when belongs to them" do
            let(:progression) do
              Fabricate(:progression, task: task, user: current_user)
            end

            it { is_expected.to be_able_to(:read, progression) }
            it { is_expected.not_to be_able_to(:update, progression) }
            it { is_expected.to be_able_to(:finish, progression) }
            it { is_expected.not_to be_able_to(:destroy, progression) }
          end

          context "when doesn't belong to them" do
            let(:progression) { Fabricate(:progression, task: task) }

            it { is_expected.to be_able_to(:read, progression) }
            it { is_expected.not_to be_able_to(:update, progression) }
            it { is_expected.not_to be_able_to(:finish, progression) }
            it { is_expected.not_to be_able_to(:destroy, progression) }
          end

          context "when no task" do
            let(:progression) do
              Fabricate(:progression, task: task, user: current_user)
            end

            before do
              task.assignees << current_user
              progression.update_attribute :task_id, 0
            end

            it { is_expected.not_to be_able_to(:create, progression) }
          end
        end

        context "for a task from an invisible project" do
          let(:project) { Fabricate(:invisible_project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when assigned to the task" do
            let(:progression) do
              Fabricate(:progression, task: task, user: current_user)
            end

            before { task.assignees << current_user }

            it { is_expected.not_to be_able_to(:create, progression) }
          end

          context "when belongs to them" do
            let(:progression) do
              Fabricate(:progression, task: task, user: current_user)
            end

            it { is_expected.to be_able_to(:read, progression) }
            it { is_expected.not_to be_able_to(:update, progression) }
            it { is_expected.not_to be_able_to(:finish, progression) }
            it { is_expected.not_to be_able_to(:destroy, progression) }
          end

          context "when doesn't belong to them" do
            let(:progression) { Fabricate(:progression, task: task) }

            it { is_expected.to be_able_to(:read, progression) }
            it { is_expected.not_to be_able_to(:update, progression) }
            it { is_expected.not_to be_able_to(:finish, progression) }
            it { is_expected.not_to be_able_to(:destroy, progression) }
          end

          context "when no task" do
            let(:progression) do
              Fabricate(:progression, task: task, user: current_user)
            end

            before do
              task.assignees << current_user
              progression.update_attribute :task_id, 0
            end

            it { is_expected.not_to be_able_to(:create, progression) }
          end
        end

        context "and task is closed" do
          let(:project) { Fabricate(:project) }
          let(:task) { Fabricate(:closed_task, project: project) }

          context "when assigned to the task" do
            let(:progression) do
              Fabricate(:progression, task: task, user: current_user)
            end

            before { task.assignees << current_user }

            it { is_expected.not_to be_able_to(:create, progression) }
          end

          context "when belongs to them" do
            let(:progression) do
              Fabricate(:progression, task: task, user: current_user)
            end

            it { is_expected.to be_able_to(:read, progression) }
            it { is_expected.not_to be_able_to(:update, progression) }
            it { is_expected.to be_able_to(:finish, progression) }
            it { is_expected.not_to be_able_to(:destroy, progression) }
          end
        end
      end
    end

    %i[worker].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        context "for a totally visible task" do
          let(:project) { Fabricate(:project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when assigned to the task" do
            let(:progression) do
              Fabricate(:progression, task: task, user: current_user)
            end

            before { task.assignees << current_user }

            it { is_expected.to be_able_to(:create, progression) }
          end

          context "when not assigned to the task" do
            let(:progression) do
              Fabricate(:progression, task: task, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, progression) }
          end

          context "when belongs to them" do
            let(:progression) do
              Fabricate(:progression, task: task, user: current_user)
            end

            it { is_expected.to be_able_to(:read, progression) }
            it { is_expected.not_to be_able_to(:update, progression) }
            it { is_expected.to be_able_to(:finish, progression) }
            it { is_expected.not_to be_able_to(:destroy, progression) }
          end

          context "when doesn't belong to them" do
            let(:progression) { Fabricate(:progression, task: task) }

            it { is_expected.to be_able_to(:read, progression) }
            it { is_expected.not_to be_able_to(:update, progression) }
            it { is_expected.not_to be_able_to(:finish, progression) }
            it { is_expected.not_to be_able_to(:destroy, progression) }
          end

          context "when no task" do
            let(:progression) do
              Fabricate(:progression, task: task, user: current_user)
            end

            before do
              task.assignees << current_user
              progression.update_attribute :task_id, 0
            end

            it { is_expected.not_to be_able_to(:create, progression) }
          end
        end

        context "for a task from an internal project" do
          let(:project) { Fabricate(:internal_project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when assigned to the task" do
            let(:progression) do
              Fabricate(:progression, task: task, user: current_user)
            end

            before { task.assignees << current_user }

            it { is_expected.to be_able_to(:create, progression) }
          end

          context "when not assigned to the task" do
            let(:progression) do
              Fabricate(:progression, task: task, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, progression) }
          end

          context "when belongs to them" do
            let(:progression) do
              Fabricate(:progression, task: task, user: current_user)
            end

            it { is_expected.to be_able_to(:read, progression) }
            it { is_expected.not_to be_able_to(:update, progression) }
            it { is_expected.to be_able_to(:finish, progression) }
            it { is_expected.not_to be_able_to(:destroy, progression) }
          end

          context "when doesn't belong to them" do
            let(:progression) { Fabricate(:progression, task: task) }

            it { is_expected.to be_able_to(:read, progression) }
            it { is_expected.not_to be_able_to(:update, progression) }
            it { is_expected.not_to be_able_to(:finish, progression) }
            it { is_expected.not_to be_able_to(:destroy, progression) }
          end

          context "when no task" do
            let(:progression) do
              Fabricate(:progression, task: task, user: current_user)
            end

            before do
              task.assignees << current_user
              progression.update_attribute :task_id, 0
            end

            it { is_expected.not_to be_able_to(:create, progression) }
          end
        end

        context "for a task from an invisible project" do
          let(:project) { Fabricate(:invisible_project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when assigned to the task" do
            let(:progression) do
              Fabricate(:progression, task: task, user: current_user)
            end

            before { task.assignees << current_user }

            it { is_expected.not_to be_able_to(:create, progression) }
          end

          context "when belongs to them" do
            let(:progression) do
              Fabricate(:progression, task: task, user: current_user)
            end

            it { is_expected.not_to be_able_to(:read, progression) }
            it { is_expected.not_to be_able_to(:update, progression) }
            it { is_expected.not_to be_able_to(:finish, progression) }
            it { is_expected.not_to be_able_to(:destroy, progression) }
          end

          context "when doesn't belong to them" do
            let(:progression) { Fabricate(:progression, task: task) }

            it { is_expected.not_to be_able_to(:read, progression) }
            it { is_expected.not_to be_able_to(:update, progression) }
            it { is_expected.not_to be_able_to(:finish, progression) }
            it { is_expected.not_to be_able_to(:destroy, progression) }
          end

          context "when no task" do
            let(:progression) do
              Fabricate(:progression, task: task, user: current_user)
            end

            before do
              task.assignees << current_user
              progression.update_attribute :task_id, 0
            end

            it { is_expected.not_to be_able_to(:create, progression) }
          end
        end

        context "and task is closed" do
          let(:project) { Fabricate(:project) }
          let(:task) { Fabricate(:closed_task, project: project) }

          context "when assigned to the task" do
            let(:progression) do
              Fabricate(:progression, task: task, user: current_user)
            end

            before { task.assignees << current_user }

            it { is_expected.not_to be_able_to(:create, progression) }
          end

          context "when belongs to them" do
            let(:progression) do
              Fabricate(:progression, task: task, user: current_user)
            end

            it { is_expected.to be_able_to(:read, progression) }
            it { is_expected.not_to be_able_to(:update, progression) }
            it { is_expected.to be_able_to(:finish, progression) }
            it { is_expected.not_to be_able_to(:destroy, progression) }
          end
        end
      end
    end

    %i[reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        context "for a totally visible task" do
          let(:project) { Fabricate(:project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when assigned to the task" do
            let(:progression) do
              Fabricate(:progression, task: task, user: current_user)
            end

            before { task.assignees << current_user }

            it { is_expected.not_to be_able_to(:create, progression) }
          end

          context "when belongs to them" do
            let(:progression) do
              Fabricate(:progression, task: task, user: current_user)
            end

            it { is_expected.to be_able_to(:read, progression) }
            it { is_expected.not_to be_able_to(:update, progression) }
            it { is_expected.not_to be_able_to(:finish, progression) }
            it { is_expected.not_to be_able_to(:destroy, progression) }
          end

          context "when doesn't belong to them" do
            let(:progression) { Fabricate(:progression, task: task) }

            it { is_expected.to be_able_to(:read, progression) }
            it { is_expected.not_to be_able_to(:update, progression) }
            it { is_expected.not_to be_able_to(:finish, progression) }
            it { is_expected.not_to be_able_to(:destroy, progression) }
          end

          context "when no task" do
            let(:progression) do
              Fabricate(:progression, task: task, user: current_user)
            end

            before do
              task.assignees << current_user
              progression.update_attribute :task_id, 0
            end

            it { is_expected.not_to be_able_to(:create, progression) }
          end
        end

        context "for a task from an internal project" do
          let(:project) { Fabricate(:internal_project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when assigned to the task" do
            let(:progression) do
              Fabricate(:progression, task: task, user: current_user)
            end

            before { task.assignees << current_user }

            it { is_expected.not_to be_able_to(:create, progression) }
          end

          context "when not assigned to the task" do
            let(:progression) do
              Fabricate(:progression, task: task, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, progression) }
          end

          context "when belongs to them" do
            let(:progression) do
              Fabricate(:progression, task: task, user: current_user)
            end

            it { is_expected.not_to be_able_to(:read, progression) }
            it { is_expected.not_to be_able_to(:update, progression) }
            it { is_expected.not_to be_able_to(:finish, progression) }
            it { is_expected.not_to be_able_to(:destroy, progression) }
          end

          context "when doesn't belong to them" do
            let(:progression) { Fabricate(:progression, task: task) }

            it { is_expected.not_to be_able_to(:read, progression) }
            it { is_expected.not_to be_able_to(:update, progression) }
            it { is_expected.not_to be_able_to(:finish, progression) }
            it { is_expected.not_to be_able_to(:destroy, progression) }
          end

          context "when no task" do
            let(:progression) do
              Fabricate(:progression, task: task, user: current_user)
            end

            before do
              task.assignees << current_user
              progression.update_attribute :task_id, 0
            end

            it { is_expected.not_to be_able_to(:create, progression) }
          end
        end

        context "for a task from an invisible project" do
          let(:project) { Fabricate(:invisible_project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when assigned to the task" do
            let(:progression) do
              Fabricate(:progression, task: task, user: current_user)
            end

            before { task.assignees << current_user }

            it { is_expected.not_to be_able_to(:create, progression) }
          end

          context "when belongs to them" do
            let(:progression) do
              Fabricate(:progression, task: task, user: current_user)
            end

            it { is_expected.not_to be_able_to(:read, progression) }
            it { is_expected.not_to be_able_to(:update, progression) }
            it { is_expected.not_to be_able_to(:finish, progression) }
            it { is_expected.not_to be_able_to(:destroy, progression) }
          end

          context "when doesn't belong to them" do
            let(:progression) { Fabricate(:progression, task: task) }

            it { is_expected.not_to be_able_to(:read, progression) }
            it { is_expected.not_to be_able_to(:update, progression) }
            it { is_expected.not_to be_able_to(:finish, progression) }
            it { is_expected.not_to be_able_to(:destroy, progression) }
          end

          context "when no task" do
            let(:progression) do
              Fabricate(:progression, task: task, user: current_user)
            end

            before do
              task.assignees << current_user
              progression.update_attribute :task_id, 0
            end

            it { is_expected.not_to be_able_to(:create, progression) }
          end
        end
      end
    end
  end

  describe "Review model" do
    let(:task) { Fabricate(:task) }

    describe "for an admin" do
      let(:admin) { Fabricate(:user_admin) }
      subject(:ability) { Ability.new(admin) }

      context "for a totally visible task" do
        let(:project) { Fabricate(:project) }
        let(:task) { Fabricate(:task, project: project) }

        context "when assigned to the task" do
          let(:review) { Fabricate.build(:review, task: task, user: admin) }

          before { task.assignees << admin }

          it { is_expected.to be_able_to(:create, review) }
        end

        context "when not assigned to the task" do
          let(:review) { Fabricate.build(:review, task: task, user: admin) }

          it { is_expected.not_to be_able_to(:create, review) }
        end

        context "when belongs to them" do
          let(:review) { Fabricate(:review, task: task, user: admin) }

          it { is_expected.to be_able_to(:read, review) }
          it { is_expected.to be_able_to(:update, review) }
          it { is_expected.to be_able_to(:approve, review) }
          it { is_expected.to be_able_to(:disapprove, review) }
        end

        context "when doesn't belong to them" do
          let(:review) { Fabricate(:review, task: task) }

          it { is_expected.to be_able_to(:read, review) }
          it { is_expected.to be_able_to(:update, review) }
          it { is_expected.not_to be_able_to(:destroy, review) }
          it { is_expected.to be_able_to(:approve, review) }
          it { is_expected.to be_able_to(:disapprove, review) }
        end

        context "when their review is pending" do
          context "and task is open" do
            let(:review) { Fabricate(:review, task: task, user: admin) }

            it { is_expected.to be_able_to(:destroy, review) }
          end

          context "and task is closed" do
            let(:task) { Fabricate(:closed_task) }
            let(:review) { Fabricate(:review, task: task, user: admin) }

            it { is_expected.not_to be_able_to(:destroy, review) }
          end
        end

        context "when their review is already approved" do
          let(:review) { Fabricate(:approved_review, task: task, user: admin) }

          it { is_expected.not_to be_able_to(:destroy, review) }
        end

        context "when their review is already disapproved" do
          let(:review) do
            Fabricate(:disapproved_review, task: task, user: admin)
          end

          it { is_expected.not_to be_able_to(:destroy, review) }
        end

        context "when review is pending" do
          let(:review) { Fabricate(:review, task: task) }

          it { is_expected.to be_able_to(:approve, review) }
          it { is_expected.to be_able_to(:disapprove, review) }
        end

        context "when review is already approved" do
          let(:review) { Fabricate(:approved_review, task: task) }

          it { is_expected.not_to be_able_to(:approve, review) }
          it { is_expected.not_to be_able_to(:disapprove, review) }
        end

        context "when review is already disapproved" do
          let(:review) { Fabricate(:disapproved_review, task: task) }

          it { is_expected.not_to be_able_to(:approve, review) }
          it { is_expected.not_to be_able_to(:disapprove, review) }
        end
      end

      context "for task from a internal project" do
        let(:project) { Fabricate(:internal_project) }
        let(:task) { Fabricate(:task, project: project) }

        context "when assigned to the task" do
          let(:review) { Fabricate.build(:review, task: task, user: admin) }

          before { task.assignees << admin }

          it { is_expected.to be_able_to(:create, review) }
        end

        context "when not assigned to the task" do
          let(:review) { Fabricate.build(:review, task: task, user: admin) }

          it { is_expected.not_to be_able_to(:create, review) }
        end

        context "when belongs to them" do
          let(:review) { Fabricate(:review, task: task, user: admin) }

          it { is_expected.to be_able_to(:read, review) }
          it { is_expected.to be_able_to(:update, review) }
          it { is_expected.to be_able_to(:approve, review) }
          it { is_expected.to be_able_to(:disapprove, review) }
        end

        context "when doesn't belong to them" do
          let(:review) { Fabricate(:review, task: task) }

          it { is_expected.to be_able_to(:read, review) }
          it { is_expected.to be_able_to(:update, review) }
          it { is_expected.not_to be_able_to(:destroy, review) }
          it { is_expected.to be_able_to(:approve, review) }
          it { is_expected.to be_able_to(:disapprove, review) }
        end

        context "when their review is pending" do
          context "and task is open" do
            let(:review) { Fabricate(:review, task: task, user: admin) }

            it { is_expected.to be_able_to(:destroy, review) }
          end

          context "and task is closed" do
            let(:task) { Fabricate(:closed_task) }
            let(:review) { Fabricate(:review, task: task, user: admin) }

            it { is_expected.not_to be_able_to(:destroy, review) }
          end
        end

        context "when their review is already approved" do
          let(:review) { Fabricate(:approved_review, task: task, user: admin) }

          it { is_expected.not_to be_able_to(:destroy, review) }
        end

        context "when their review is already disapproved" do
          let(:review) do
            Fabricate(:disapproved_review, task: task, user: admin)
          end

          it { is_expected.not_to be_able_to(:destroy, review) }
        end

        context "when review is pending" do
          let(:review) { Fabricate(:review, task: task) }

          it { is_expected.to be_able_to(:approve, review) }
          it { is_expected.to be_able_to(:disapprove, review) }
        end

        context "when review is already approved" do
          let(:review) { Fabricate(:approved_review, task: task) }

          it { is_expected.not_to be_able_to(:approve, review) }
          it { is_expected.not_to be_able_to(:disapprove, review) }
        end

        context "when review is already disapproved" do
          let(:review) { Fabricate(:disapproved_review, task: task) }

          it { is_expected.not_to be_able_to(:approve, review) }
          it { is_expected.not_to be_able_to(:disapprove, review) }
        end
      end

      context "for task from a invisible project" do
        let(:project) { Fabricate(:invisible_project) }
        let(:task) { Fabricate(:task, project: project) }

        context "when assigned to the task" do
          let(:review) { Fabricate.build(:review, task: task, user: admin) }

          before { task.assignees << admin }

          it { is_expected.not_to be_able_to(:create, review) }
        end

        context "when not assigned to the task" do
          let(:review) { Fabricate.build(:review, task: task, user: admin) }

          it { is_expected.not_to be_able_to(:create, review) }
        end

        context "when belongs to them" do
          let(:review) { Fabricate(:review, task: task, user: admin) }

          it { is_expected.to be_able_to(:read, review) }
          it { is_expected.to be_able_to(:update, review) }
          it { is_expected.to be_able_to(:approve, review) }
          it { is_expected.to be_able_to(:disapprove, review) }
        end

        context "when doesn't belong to them" do
          let(:review) { Fabricate(:review, task: task) }

          it { is_expected.to be_able_to(:read, review) }
          it { is_expected.to be_able_to(:update, review) }
          it { is_expected.not_to be_able_to(:destroy, review) }
          it { is_expected.to be_able_to(:approve, review) }
          it { is_expected.to be_able_to(:disapprove, review) }
        end

        context "when their review is pending" do
          context "and task is open" do
            let(:review) { Fabricate(:review, task: task, user: admin) }

            it { is_expected.to be_able_to(:destroy, review) }
          end

          context "and task is closed" do
            let(:task) { Fabricate(:closed_task) }
            let(:review) { Fabricate(:review, task: task, user: admin) }

            it { is_expected.not_to be_able_to(:destroy, review) }
          end
        end

        context "when their review is already approved" do
          let(:review) { Fabricate(:approved_review, task: task, user: admin) }

          it { is_expected.not_to be_able_to(:destroy, review) }
        end

        context "when their review is already disapproved" do
          let(:review) do
            Fabricate(:disapproved_review, task: task, user: admin)
          end

          it { is_expected.not_to be_able_to(:destroy, review) }
        end

        context "when review is pending" do
          let(:review) { Fabricate(:review, task: task) }

          it { is_expected.to be_able_to(:approve, review) }
          it { is_expected.to be_able_to(:disapprove, review) }
        end

        context "when review is already approved" do
          let(:review) { Fabricate(:approved_review, task: task) }

          it { is_expected.not_to be_able_to(:approve, review) }
          it { is_expected.not_to be_able_to(:disapprove, review) }
        end

        context "when review is already disapproved" do
          let(:review) { Fabricate(:disapproved_review, task: task) }

          it { is_expected.not_to be_able_to(:approve, review) }
          it { is_expected.not_to be_able_to(:disapprove, review) }
        end
      end

      context "for closed task" do
        let(:project) { Fabricate(:project) }
        let(:task) { Fabricate(:closed_task, project: project) }

        context "when assigned to the task" do
          let(:review) { Fabricate.build(:review, task: task, user: admin) }

          before { task.assignees << admin }

          it { is_expected.not_to be_able_to(:create, review) }
        end

        context "when belongs to them" do
          let(:review) { Fabricate(:review, task: task, user: admin) }

          it { is_expected.to be_able_to(:read, review) }
          it { is_expected.to be_able_to(:update, review) }
          it { is_expected.to be_able_to(:approve, review) }
          it { is_expected.to be_able_to(:disapprove, review) }
          it { is_expected.not_to be_able_to(:destroy, review) }
        end
      end
    end

    %i[reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        context "for a totally visible task" do
          let(:project) { Fabricate(:project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when assigned to the task" do
            let(:review) do
              Fabricate.build(:review, task: task, user: current_user)
            end

            before { task.assignees << current_user }

            it { is_expected.to be_able_to(:create, review) }
          end

          context "when not assigned to the task" do
            let(:review) do
              Fabricate.build(:review, task: task, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, review) }
          end

          context "when belongs to them" do
            let(:review) { Fabricate(:review, task: task, user: current_user) }

            it { is_expected.to be_able_to(:read, review) }
            it { is_expected.not_to be_able_to(:update, review) }
            it { is_expected.to be_able_to(:approve, review) }
            it { is_expected.to be_able_to(:disapprove, review) }
          end

          context "when doesn't belong to them" do
            let(:review) { Fabricate(:review, task: task) }

            it { is_expected.to be_able_to(:read, review) }
            it { is_expected.not_to be_able_to(:update, review) }
            it { is_expected.not_to be_able_to(:destroy, review) }
            it { is_expected.to be_able_to(:approve, review) }
            it { is_expected.to be_able_to(:disapprove, review) }
          end

          context "when their review is pending" do
            context "and task is open" do
              let(:review) do
                Fabricate(:review, task: task, user: current_user)
              end

              it { is_expected.to be_able_to(:destroy, review) }
            end

            context "and task is closed" do
              let(:task) { Fabricate(:closed_task) }
              let(:review) do
                Fabricate(:review, task: task, user: current_user)
              end

              it { is_expected.not_to be_able_to(:destroy, review) }
            end
          end

          context "when already approved" do
            let(:review) do
              Fabricate(:approved_review, task: task, user: current_user)
            end

            it { is_expected.not_to be_able_to(:destroy, review) }
          end

          context "when already disapproved" do
            let(:review) do
              Fabricate(:disapproved_review, task: task, user: current_user)
            end

            it { is_expected.not_to be_able_to(:destroy, review) }
          end
        end

        context "for a task from a internal project" do
          let(:project) { Fabricate(:internal_project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when assigned to the task" do
            let(:review) do
              Fabricate.build(:review, task: task, user: current_user)
            end

            before { task.assignees << current_user }

            it { is_expected.to be_able_to(:create, review) }
          end

          context "when not assigned to the task" do
            let(:review) do
              Fabricate.build(:review, task: task, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, review) }
          end

          context "when belongs to them" do
            let(:review) { Fabricate(:review, task: task, user: current_user) }

            it { is_expected.to be_able_to(:read, review) }
            it { is_expected.not_to be_able_to(:update, review) }
            it { is_expected.to be_able_to(:approve, review) }
            it { is_expected.to be_able_to(:disapprove, review) }
          end

          context "when doesn't belong to them" do
            let(:review) { Fabricate(:review, task: task) }

            it { is_expected.to be_able_to(:read, review) }
            it { is_expected.not_to be_able_to(:update, review) }
            it { is_expected.not_to be_able_to(:destroy, review) }
            it { is_expected.to be_able_to(:approve, review) }
            it { is_expected.to be_able_to(:disapprove, review) }
          end

          context "when their review is pending" do
            context "and task is open" do
              let(:review) do
                Fabricate(:review, task: task, user: current_user)
              end

              it { is_expected.to be_able_to(:destroy, review) }
            end

            context "and task is closed" do
              let(:task) { Fabricate(:closed_task) }
              let(:review) do
                Fabricate(:review, task: task, user: current_user)
              end

              it { is_expected.not_to be_able_to(:destroy, review) }
            end
          end

          context "when already approved" do
            let(:review) do
              Fabricate(:approved_review, task: task, user: current_user)
            end

            it { is_expected.not_to be_able_to(:destroy, review) }
          end

          context "when already disapproved" do
            let(:review) do
              Fabricate(:disapproved_review, task: task, user: current_user)
            end

            it { is_expected.not_to be_able_to(:destroy, review) }
          end
        end

        context "for a task from a invisible project" do
          let(:project) { Fabricate(:invisible_project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when assigned to the task" do
            let(:review) do
              Fabricate.build(:review, task: task, user: current_user)
            end

            before { task.assignees << current_user }

            it { is_expected.not_to be_able_to(:create, review) }
          end

          context "when not assigned to the task" do
            let(:review) do
              Fabricate.build(:review, task: task, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, review) }
          end

          context "when belongs to them" do
            let(:review) { Fabricate(:review, task: task, user: current_user) }

            it { is_expected.to be_able_to(:read, review) }
            it { is_expected.not_to be_able_to(:update, review) }
            it { is_expected.not_to be_able_to(:approve, review) }
            it { is_expected.not_to be_able_to(:disapprove, review) }
          end

          context "when doesn't belong to them" do
            let(:review) { Fabricate(:review, task: task) }

            it { is_expected.to be_able_to(:read, review) }
            it { is_expected.not_to be_able_to(:update, review) }
            it { is_expected.not_to be_able_to(:destroy, review) }
            it { is_expected.not_to be_able_to(:approve, review) }
            it { is_expected.not_to be_able_to(:disapprove, review) }
          end

          context "when their review is pending" do
            context "and task is open" do
              let(:review) do
                Fabricate(:review, task: task, user: current_user)
              end

              it { is_expected.not_to be_able_to(:destroy, review) }
            end
          end
        end

        context "for a closed task" do
          let(:project) { Fabricate(:project) }
          let(:task) { Fabricate(:closed_task, project: project) }

          context "when assigned to the task" do
            let(:review) do
              Fabricate.build(:review, task: task, user: current_user)
            end

            before { task.assignees << current_user }

            it { is_expected.not_to be_able_to(:create, review) }
          end

          context "when belongs to them" do
            let(:review) { Fabricate(:review, task: task, user: current_user) }

            it { is_expected.to be_able_to(:read, review) }
            it { is_expected.not_to be_able_to(:update, review) }
            it { is_expected.to be_able_to(:approve, review) }
            it { is_expected.to be_able_to(:disapprove, review) }
          end
        end
      end
    end

    %i[worker].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        context "for a totally visible task" do
          let(:project) { Fabricate(:project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when assigned to the task" do
            let(:review) do
              Fabricate.build(:review, task: task, user: current_user)
            end

            before { task.assignees << current_user }

            it { is_expected.to be_able_to(:create, review) }
          end

          context "when not assigned to the task" do
            let(:review) do
              Fabricate.build(:review, task: task, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, review) }
          end

          context "when belongs to them" do
            let(:review) { Fabricate(:review, task: task, user: current_user) }

            it { is_expected.to be_able_to(:read, review) }
            it { is_expected.not_to be_able_to(:update, review) }
            it { is_expected.to be_able_to(:destroy, review) }
            it { is_expected.not_to be_able_to(:approve, review) }
            it { is_expected.not_to be_able_to(:disapprove, review) }
          end

          context "when doesn't belong to them" do
            let(:review) { Fabricate(:review, task: task) }

            it { is_expected.to be_able_to(:read, review) }
            it { is_expected.not_to be_able_to(:update, review) }
            it { is_expected.not_to be_able_to(:destroy, review) }
            it { is_expected.not_to be_able_to(:approve, review) }
            it { is_expected.not_to be_able_to(:disapprove, review) }
          end
        end

        context "for a task from an internal project" do
          let(:project) { Fabricate(:internal_project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when assigned to the task" do
            let(:review) do
              Fabricate.build(:review, task: task, user: current_user)
            end

            before { task.assignees << current_user }

            it { is_expected.to be_able_to(:create, review) }
          end

          context "when belongs to them" do
            let(:review) { Fabricate(:review, task: task, user: current_user) }

            it { is_expected.to be_able_to(:read, review) }
            it { is_expected.not_to be_able_to(:update, review) }
            it { is_expected.to be_able_to(:destroy, review) }
            it { is_expected.not_to be_able_to(:approve, review) }
            it { is_expected.not_to be_able_to(:disapprove, review) }
          end

          context "when doesn't belong to them" do
            let(:review) { Fabricate(:review, task: task) }

            it { is_expected.to be_able_to(:read, review) }
            it { is_expected.not_to be_able_to(:update, review) }
            it { is_expected.not_to be_able_to(:destroy, review) }
            it { is_expected.not_to be_able_to(:approve, review) }
            it { is_expected.not_to be_able_to(:disapprove, review) }
          end
        end

        context "for a task from an invisible project" do
          let(:project) { Fabricate(:invisible_project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when assigned to the task" do
            let(:review) do
              Fabricate.build(:review, task: task, user: current_user)
            end

            before { task.assignees << current_user }

            it { is_expected.not_to be_able_to(:create, review) }
          end

          context "when belongs to them" do
            let(:review) { Fabricate(:review, task: task, user: current_user) }

            it { is_expected.not_to be_able_to(:read, review) }
            it { is_expected.not_to be_able_to(:update, review) }
            it { is_expected.not_to be_able_to(:destroy, review) }
            it { is_expected.not_to be_able_to(:approve, review) }
            it { is_expected.not_to be_able_to(:disapprove, review) }
          end

          context "when doesn't belong to them" do
            let(:review) { Fabricate(:review, task: task) }

            it { is_expected.not_to be_able_to(:read, review) }
            it { is_expected.not_to be_able_to(:update, review) }
            it { is_expected.not_to be_able_to(:destroy, review) }
            it { is_expected.not_to be_able_to(:approve, review) }
            it { is_expected.not_to be_able_to(:disapprove, review) }
          end
        end

        context "for a closed task" do
          let(:project) { Fabricate(:project) }
          let(:task) { Fabricate(:closed_task, project: project) }

          context "when assigned to the task" do
            let(:review) do
              Fabricate.build(:review, task: task, user: current_user)
            end

            before { task.assignees << current_user }

            it { is_expected.not_to be_able_to(:create, review) }
          end

          context "when belongs to them" do
            let(:review) { Fabricate(:review, task: task, user: current_user) }

            it { is_expected.to be_able_to(:read, review) }
            it { is_expected.not_to be_able_to(:update, review) }
            it { is_expected.not_to be_able_to(:destroy, review) }
            it { is_expected.not_to be_able_to(:approve, review) }
            it { is_expected.not_to be_able_to(:disapprove, review) }
          end
        end
      end
    end

    %i[reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        context "for a totally visible task" do
          let(:project) { Fabricate(:project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when assigned to the task" do
            let(:review) do
              Fabricate.build(:review, task: task, user: current_user)
            end

            before { task.assignees << current_user }

            it { is_expected.not_to be_able_to(:create, review) }
          end

          context "when not assigned to the task" do
            let(:review) do
              Fabricate.build(:review, task: task, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, review) }
          end

          context "when belongs to them" do
            let(:review) { Fabricate(:review, task: task, user: current_user) }

            it { is_expected.to be_able_to(:read, review) }
            it { is_expected.not_to be_able_to(:update, review) }
            it { is_expected.not_to be_able_to(:destroy, review) }
            it { is_expected.not_to be_able_to(:approve, review) }
            it { is_expected.not_to be_able_to(:disapprove, review) }
          end

          context "when doesn't belong to them" do
            let(:review) { Fabricate(:review, task: task) }

            it { is_expected.to be_able_to(:read, review) }
            it { is_expected.not_to be_able_to(:update, review) }
            it { is_expected.not_to be_able_to(:destroy, review) }
            it { is_expected.not_to be_able_to(:approve, review) }
            it { is_expected.not_to be_able_to(:disapprove, review) }
          end
        end

        context "for a closed task" do
          let(:project) { Fabricate(:project) }
          let(:task) { Fabricate(:closed_task, project: project) }

          context "when assigned to the task" do
            let(:review) do
              Fabricate.build(:review, task: task, user: current_user)
            end

            before { task.assignees << current_user }

            it { is_expected.not_to be_able_to(:create, review) }
          end

          context "when belongs to them" do
            let(:review) { Fabricate(:review, task: task, user: current_user) }

            it { is_expected.to be_able_to(:read, review) }
            it { is_expected.not_to be_able_to(:update, review) }
            it { is_expected.not_to be_able_to(:destroy, review) }
            it { is_expected.not_to be_able_to(:approve, review) }
            it { is_expected.not_to be_able_to(:disapprove, review) }
          end
        end
      end
    end
  end

  describe "Task model" do
    describe "for an admin" do
      let(:category) { Fabricate(:category) }
      let(:project) { Fabricate(:project, category: category) }
      let(:admin) { Fabricate(:user_admin) }

      subject(:ability) { Ability.new(admin) }

      context "when task category is visible" do
        context "and external" do
          context "while project is visible" do
            context "and external" do
              context "when belongs to them" do
                let(:task) { Fabricate(:task, project: project, user: admin) }

                it { is_expected.to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
                it { is_expected.to be_able_to(:self_assign, task) }
              end

              context "when doesn't belong to them" do
                let(:task) { Fabricate(:task, project: project) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
                it { is_expected.to be_able_to(:self_assign, task) }
              end

              context "and closed" do
                let(:task) { Fabricate(:closed_task, project: project) }

                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
                it { is_expected.to be_able_to(:self_assign, task) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:project, category: category, internal: true)
              end

              context "when belongs to them" do
                let(:task) { Fabricate(:task, project: project, user: admin) }

                it { is_expected.to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
                it { is_expected.to be_able_to(:self_assign, task) }
              end

              context "when doesn't belong to them" do
                let(:task) { Fabricate(:task, project: project) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
                it { is_expected.to be_able_to(:self_assign, task) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:task) { Fabricate(:task, project: project, user: admin) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
                it { is_expected.to be_able_to(:self_assign, task) }
              end

              context "when doesn't belong to them" do
                let(:task) { Fabricate(:task, project: project) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
                it { is_expected.to be_able_to(:self_assign, task) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:project, category: category, visible: false,
                                    internal: true)
              end

              context "when belongs to them" do
                let(:task) { Fabricate(:task, project: project, user: admin) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
                it { is_expected.to be_able_to(:self_assign, task) }
              end

              context "when doesn't belong to them" do
                let(:task) { Fabricate(:task, project: project) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
                it { is_expected.to be_able_to(:self_assign, task) }
              end
            end
          end
        end
      end

      context "when task category is invisible" do
        context "and external" do
          let(:category) { Fabricate(:category, visible: false) }

          context "while project is visible" do
            context "and external" do
              context "when belongs to them" do
                let(:task) { Fabricate(:task, project: project, user: admin) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
                it { is_expected.to be_able_to(:self_assign, task) }
              end

              context "when doesn't belong to them" do
                let(:task) { Fabricate(:task, project: project) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
                it { is_expected.to be_able_to(:self_assign, task) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:project, category: category, internal: true)
              end

              context "when belongs to them" do
                let(:task) { Fabricate(:task, project: project, user: admin) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
                it { is_expected.to be_able_to(:self_assign, task) }
              end

              context "when doesn't belong to them" do
                let(:task) { Fabricate(:task, project: project) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
                it { is_expected.to be_able_to(:self_assign, task) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:task) { Fabricate(:task, project: project, user: admin) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
                it { is_expected.to be_able_to(:self_assign, task) }
              end

              context "when doesn't belong to them" do
                let(:task) { Fabricate(:task, project: project) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
                it { is_expected.to be_able_to(:self_assign, task) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:project, category: category, visible: false,
                                    internal: true)
              end

              context "when belongs to them" do
                let(:task) { Fabricate(:task, project: project, user: admin) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
                it { is_expected.to be_able_to(:self_assign, task) }
              end

              context "when doesn't belong to them" do
                let(:task) { Fabricate(:task, project: project) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
                it { is_expected.to be_able_to(:self_assign, task) }
              end
            end
          end
        end
      end
    end

    describe "for a reviewer" do
      let(:category) { Fabricate(:category) }
      let(:project) { Fabricate(:project, category: category) }
      let(:current_user) { Fabricate(:user_reviewer) }

      subject(:ability) { Ability.new(current_user) }

      context "when task category is visible" do
        context "and external" do
          context "while project is visible" do
            context "and external" do
              context "when belongs to them" do
                let(:task) do
                  Fabricate(:task, project: project, user: current_user)
                end

                it { is_expected.to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
                it { is_expected.to be_able_to(:self_assign, task) }
              end

              context "when doesn't belong to them" do
                let(:task) { Fabricate(:task, project: project) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
                it { is_expected.to be_able_to(:self_assign, task) }
              end

              context "and closed" do
                let(:task) { Fabricate(:closed_task, project: project) }

                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:assign, task) }
                it { is_expected.not_to be_able_to(:self_assign, task) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:project, category: category, internal: true)
              end

              context "when belongs to them" do
                let(:task) do
                  Fabricate(:task, project: project, user: current_user)
                end

                it { is_expected.to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
                it { is_expected.to be_able_to(:self_assign, task) }
              end

              context "when doesn't belong to them" do
                let(:task) { Fabricate(:task, project: project) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
                it { is_expected.to be_able_to(:self_assign, task) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:task) do
                  Fabricate(:task, project: project, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.not_to be_able_to(:assign, task) }
                it { is_expected.not_to be_able_to(:self_assign, task) }
              end

              context "when doesn't belong to them" do
                let(:task) { Fabricate(:task, project: project) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.not_to be_able_to(:assign, task) }
                it { is_expected.not_to be_able_to(:self_assign, task) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:project, category: category, visible: false,
                                    internal: true)
              end

              context "when belongs to them" do
                let(:task) do
                  Fabricate(:task, project: project, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.not_to be_able_to(:assign, task) }
                it { is_expected.not_to be_able_to(:self_assign, task) }
              end

              context "when doesn't belong to them" do
                let(:task) { Fabricate(:task, project: project) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.not_to be_able_to(:assign, task) }
                it { is_expected.not_to be_able_to(:self_assign, task) }
              end
            end
          end
        end
      end

      context "when task category is invisible" do
        context "and external" do
          let(:category) { Fabricate(:category, visible: false) }

          context "while project is visible" do
            context "and external" do
              context "when belongs to them" do
                let(:task) do
                  Fabricate(:task, project: project, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.not_to be_able_to(:assign, task) }
                it { is_expected.not_to be_able_to(:self_assign, task) }
              end

              context "when doesn't belong to them" do
                let(:task) { Fabricate(:task, project: project) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.not_to be_able_to(:assign, task) }
                it { is_expected.not_to be_able_to(:self_assign, task) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:project, category: category, internal: true)
              end

              context "when belongs to them" do
                let(:task) do
                  Fabricate(:task, project: project, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.not_to be_able_to(:assign, task) }
                it { is_expected.not_to be_able_to(:self_assign, task) }
              end

              context "when doesn't belong to them" do
                let(:task) { Fabricate(:task, project: project) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.not_to be_able_to(:assign, task) }
                it { is_expected.not_to be_able_to(:self_assign, task) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:task) do
                  Fabricate(:task, project: project, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.not_to be_able_to(:assign, task) }
                it { is_expected.not_to be_able_to(:self_assign, task) }
              end

              context "when doesn't belong to them" do
                let(:task) { Fabricate(:task, project: project) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.not_to be_able_to(:assign, task) }
                it { is_expected.not_to be_able_to(:self_assign, task) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:project, category: category, visible: false,
                                    internal: true)
              end

              context "when belongs to them" do
                let(:task) do
                  Fabricate(:task, project: project, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.not_to be_able_to(:assign, task) }
                it { is_expected.not_to be_able_to(:self_assign, task) }
              end

              context "when doesn't belong to them" do
                let(:task) { Fabricate(:task, project: project) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.not_to be_able_to(:assign, task) }
                it { is_expected.not_to be_able_to(:self_assign, task) }
              end
            end
          end
        end
      end
    end

    %i[worker].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        let(:category) { Fabricate(:category) }
        let(:project) { Fabricate(:project, category: category) }

        subject(:ability) { Ability.new(current_user) }

        context "when category is visible" do
          context "and external" do
            context "while project is visible" do
              context "and external" do
                context "when belongs to them" do
                  let(:task) do
                    Fabricate(:task, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                  it { is_expected.to be_able_to(:self_assign, task) }
                end

                context "when doesn't belong to them" do
                  let(:task) { Fabricate(:task, project: project) }

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                  it { is_expected.to be_able_to(:self_assign, task) }
                end

                context "and closed" do
                  let(:task) { Fabricate(:closed_task, project: project) }

                  it { is_expected.to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:self_assign, task) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, internal: true)
                end

                context "when belongs to them" do
                  let(:task) do
                    Fabricate(:task, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                  it { is_expected.to be_able_to(:self_assign, task) }
                end

                context "when doesn't belong to them" do
                  let(:task) { Fabricate(:task, project: project) }

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                  it { is_expected.to be_able_to(:self_assign, task) }
                end
              end
            end

            context "while project is invisible" do
              context "and external" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: false)
                end

                context "when belongs to them" do
                  let(:task) do
                    Fabricate(:task, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                  it { is_expected.not_to be_able_to(:self_assign, task) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: true)
                end

                context "when belongs to them" do
                  let(:task) do
                    Fabricate(:task, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                  it { is_expected.not_to be_able_to(:self_assign, task) }
                end
              end
            end
          end
        end

        context "when category is invisible" do
          context "and external" do
            let(:category) { Fabricate(:category, visible: false) }

            context "while project is visible" do
              context "and external" do
                context "when belongs to them" do
                  let(:task) do
                    Fabricate(:task, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                  it { is_expected.not_to be_able_to(:self_assign, task) }
                end
              end
            end

            context "while project is invisible" do
              context "and external" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: false)
                end

                context "when belongs to them" do
                  let(:task) do
                    Fabricate(:task, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                  it { is_expected.not_to be_able_to(:self_assign, task) }
                end
              end
            end
          end

          context "and internal" do
            let(:category) do
              Fabricate(:category, visible: true, internal: true)
            end

            context "while project is visible" do
              context "and external" do
                let(:task) do
                  Fabricate(:task, project: project, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.not_to be_able_to(:assign, task) }
                it { is_expected.to be_able_to(:self_assign, task) }
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, internal: true)
                end

                let(:task) do
                  Fabricate(:task, project: project, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.not_to be_able_to(:assign, task) }
                it { is_expected.to be_able_to(:self_assign, task) }
              end
            end

            context "while project is invisible" do
              context "and external" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: false)
                end

                let(:task) do
                  Fabricate(:task, project: project, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.not_to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.not_to be_able_to(:assign, task) }
                it { is_expected.not_to be_able_to(:self_assign, task) }
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: true)
                end

                let(:task) do
                  Fabricate(:task, project: project, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.not_to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.not_to be_able_to(:assign, task) }
                it { is_expected.not_to be_able_to(:self_assign, task) }
              end
            end
          end
        end
      end
    end

    %i[reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        let(:category) { Fabricate(:category) }
        let(:project) { Fabricate(:project, category: category) }

        subject(:ability) { Ability.new(current_user) }

        context "when category is visible" do
          context "and external" do
            context "while project is visible" do
              context "and external" do
                let(:task) { Fabricate(:task, project: project) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.not_to be_able_to(:assign, task) }
                it { is_expected.not_to be_able_to(:self_assign, task) }
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, internal: true)
                end

                let(:task) do
                  Fabricate(:task, project: project, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.not_to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.not_to be_able_to(:assign, task) }
                it { is_expected.not_to be_able_to(:self_assign, task) }
              end
            end

            context "while project is invisible" do
              context "and external" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: false)
                end

                let(:task) do
                  Fabricate(:task, project: project, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.not_to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.not_to be_able_to(:assign, task) }
                it { is_expected.not_to be_able_to(:self_assign, task) }
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: true)
                end

                let(:task) do
                  Fabricate(:task, project: project, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.not_to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.not_to be_able_to(:assign, task) }
                it { is_expected.not_to be_able_to(:self_assign, task) }
              end
            end
          end
        end

        context "when category is invisible" do
          context "and external" do
            let(:category) { Fabricate(:category, visible: false) }

            context "while project is visible" do
              context "and external" do
                let(:task) do
                  Fabricate(:task, project: project, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.not_to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.not_to be_able_to(:assign, task) }
                it { is_expected.not_to be_able_to(:self_assign, task) }
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, internal: true)
                end

                let(:task) do
                  Fabricate(:task, project: project, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.not_to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.not_to be_able_to(:assign, task) }
                it { is_expected.not_to be_able_to(:self_assign, task) }
              end
            end

            context "while project is invisible" do
              context "and external" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: false)
                end

                let(:task) do
                  Fabricate(:task, project: project, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.not_to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.not_to be_able_to(:assign, task) }
                it { is_expected.not_to be_able_to(:self_assign, task) }
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: true)
                end

                let(:task) do
                  Fabricate(:task, project: project, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.not_to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.not_to be_able_to(:assign, task) }
                it { is_expected.not_to be_able_to(:self_assign, task) }
              end
            end
          end

          context "and internal" do
            let(:category) do
              Fabricate(:category, visible: true, internal: true)
            end

            context "while project is visible" do
              context "and external" do
                let(:task) do
                  Fabricate(:task, project: project, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.not_to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.not_to be_able_to(:assign, task) }
                it { is_expected.not_to be_able_to(:self_assign, task) }
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, internal: true)
                end

                let(:task) do
                  Fabricate(:task, project: project, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.not_to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.not_to be_able_to(:assign, task) }
                it { is_expected.not_to be_able_to(:self_assign, task) }
              end
            end

            context "while project is invisible" do
              context "and external" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: false)
                end

                let(:task) do
                  Fabricate(:task, project: project, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.not_to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.not_to be_able_to(:assign, task) }
                it { is_expected.not_to be_able_to(:self_assign, task) }
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: true)
                end

                let(:task) do
                  Fabricate(:task, project: project, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.not_to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.not_to be_able_to(:assign, task) }
                it { is_expected.not_to be_able_to(:self_assign, task) }
              end
            end
          end
        end
      end
    end
  end

  describe "TaskComment model" do
    describe "for an admin" do
      let(:task) { Fabricate(:task, project: project) }
      let(:admin) { Fabricate(:user_admin) }
      subject(:ability) { Ability.new(admin) }

      context "when category is visible" do
        context "and external" do
          let(:category) { Fabricate(:category) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: admin)
                end

                it { is_expected.to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: admin)
                end

                it { is_expected.to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end
            end

            context "and task is closed" do
              let(:project) { Fabricate(:project, category: category) }
              let(:task) { Fabricate(:closed_task, project: project) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: admin)
                end

                it { is_expected.to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:invisible_project, category: category)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: admin)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:internal_project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: admin)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end
            end
          end
        end

        context "and internal" do
          let(:category) { Fabricate(:internal_category) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: admin)
                end

                it { is_expected.to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: admin)
                end

                it { is_expected.to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:invisible_project, category: category)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: admin)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:internal_project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: admin)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end
            end
          end
        end
      end

      context "when category is invisible" do
        context "and external" do
          let(:category) { Fabricate(:invisible_category) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: admin)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: admin)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end
            end
          end
        end

        context "and internal" do
          let(:category) { Fabricate(:invisible_category, internal: true) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: admin)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: admin)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:invisible_project, category: category)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: admin)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:internal_project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: admin)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end
            end
          end
        end
      end
    end

    describe "for a reviewer" do
      let(:task) { Fabricate(:task, project: project) }
      let(:current_user) { Fabricate(:user_reviewer) }
      subject(:ability) { Ability.new(current_user) }

      context "when category is visible" do
        context "and external" do
          let(:category) { Fabricate(:category) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end

            context "and task is closed" do
              let(:project) { Fabricate(:project, category: category) }
              let(:task) { Fabricate(:closed_task, project: project) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:invisible_project, category: category)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:internal_project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end
        end

        context "and internal" do
          let(:category) { Fabricate(:internal_category) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:invisible_project, category: category)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:internal_project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end
        end
      end

      context "when category is invisible" do
        context "and external" do
          let(:category) { Fabricate(:invisible_category) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end
        end

        context "and internal" do
          let(:category) { Fabricate(:invisible_category, internal: true) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:invisible_project, category: category)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:internal_project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end
        end
      end
    end

    describe "for a worker" do
      let(:task) { Fabricate(:task, project: project) }
      let(:current_user) { Fabricate(:user_worker) }
      subject(:ability) { Ability.new(current_user) }

      context "when category is visible" do
        context "and external" do
          let(:category) { Fabricate(:category) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end

            context "and task is closed" do
              let(:project) { Fabricate(:project, category: category) }
              let(:task) { Fabricate(:closed_task, project: project) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:invisible_project, category: category)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:internal_project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end
        end

        context "and internal" do
          let(:category) { Fabricate(:internal_category) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:invisible_project, category: category)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:internal_project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end
        end
      end

      context "when category is invisible" do
        context "and external" do
          let(:category) { Fabricate(:invisible_category) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end
        end

        context "and internal" do
          let(:category) { Fabricate(:invisible_category, internal: true) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end
        end
      end
    end

    describe "for a reporter" do
      let(:task) { Fabricate(:task, project: project) }
      let(:current_user) { Fabricate(:user_reporter) }
      subject(:ability) { Ability.new(current_user) }

      context "when category is visible" do
        context "and external" do
          let(:category) { Fabricate(:category) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end

            context "and task is closed" do
              let(:project) { Fabricate(:project, category: category) }
              let(:task) { Fabricate(:closed_task, project: project) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:invisible_project, category: category)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:internal_project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end
        end

        context "and internal" do
          let(:category) { Fabricate(:internal_category) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:invisible_project, category: category)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end
        end
      end

      context "when category is invisible" do
        context "and external" do
          let(:category) { Fabricate(:invisible_category) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end
        end
      end
    end
  end

  describe "TaskConnection model" do
    %i[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        subject(:ability) { Ability.new(current_user) }

        context "for a totally visible task" do
          let(:project) { Fabricate(:project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when their connection" do
            let(:task_connection) do
              Fabricate(:task_connection, source: task, user: current_user)
            end

            it { is_expected.to be_able_to(:create, task_connection) }
            it { is_expected.to be_able_to(:read, task_connection) }
            it { is_expected.to be_able_to(:update, task_connection) }
            it { is_expected.to be_able_to(:destroy, task_connection) }
          end

          context "when someone else's connection" do
            let(:task_connection) do
              Fabricate(:task_connection, source: task)
            end

            it { is_expected.not_to be_able_to(:create, task_connection) }
            it { is_expected.to be_able_to(:read, task_connection) }
            it { is_expected.not_to be_able_to(:update, task_connection) }
            it { is_expected.to be_able_to(:destroy, task_connection) }
          end
        end

        context "for a task from an internal project" do
          let(:project) { Fabricate(:internal_project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when their connection" do
            let(:task_connection) do
              Fabricate(:task_connection, source: task, user: current_user)
            end

            it { is_expected.to be_able_to(:create, task_connection) }
            it { is_expected.to be_able_to(:read, task_connection) }
            it { is_expected.to be_able_to(:update, task_connection) }
            it { is_expected.to be_able_to(:destroy, task_connection) }
          end

          context "when someone else's connection" do
            let(:task_connection) do
              Fabricate(:task_connection, source: task)
            end

            it { is_expected.not_to be_able_to(:create, task_connection) }
            it { is_expected.to be_able_to(:read, task_connection) }
            it { is_expected.not_to be_able_to(:update, task_connection) }
            it { is_expected.to be_able_to(:destroy, task_connection) }
          end
        end

        context "for a task from an invisible project" do
          let(:project) { Fabricate(:invisible_project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when their connection" do
            let(:task_connection) do
              Fabricate(:task_connection, source: task, user: current_user)
            end

            it { is_expected.to be_able_to(:create, task_connection) }
            it { is_expected.to be_able_to(:read, task_connection) }
            it { is_expected.to be_able_to(:update, task_connection) }
            it { is_expected.to be_able_to(:destroy, task_connection) }
          end

          context "when someone else's connection" do
            let(:task_connection) do
              Fabricate(:task_connection, source: task)
            end

            it { is_expected.not_to be_able_to(:create, task_connection) }
            it { is_expected.to be_able_to(:read, task_connection) }
            it { is_expected.not_to be_able_to(:update, task_connection) }
            it { is_expected.to be_able_to(:destroy, task_connection) }
          end
        end
      end
    end

    %i[reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        subject(:ability) { Ability.new(current_user) }

        context "for a totally visible task" do
          let(:project) { Fabricate(:project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when their connection" do
            let(:task_connection) do
              Fabricate(:task_connection, source: task, user: current_user)
            end

            it { is_expected.to be_able_to(:create, task_connection) }
            it { is_expected.to be_able_to(:read, task_connection) }
            it { is_expected.to be_able_to(:update, task_connection) }
            it { is_expected.to be_able_to(:destroy, task_connection) }
          end

          context "when someone else's connection" do
            let(:task_connection) do
              Fabricate(:task_connection, source: task)
            end

            it { is_expected.not_to be_able_to(:create, task_connection) }
            it { is_expected.to be_able_to(:read, task_connection) }
            it { is_expected.not_to be_able_to(:update, task_connection) }
            it { is_expected.to be_able_to(:destroy, task_connection) }
          end
        end

        context "for a task from an internal project" do
          let(:project) { Fabricate(:internal_project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when their connection" do
            let(:task_connection) do
              Fabricate(:task_connection, source: task, user: current_user)
            end

            it { is_expected.to be_able_to(:create, task_connection) }
            it { is_expected.to be_able_to(:read, task_connection) }
            it { is_expected.to be_able_to(:update, task_connection) }
            it { is_expected.to be_able_to(:destroy, task_connection) }
          end

          context "when someone else's connection" do
            let(:task_connection) do
              Fabricate(:task_connection, source: task)
            end

            it { is_expected.not_to be_able_to(:create, task_connection) }
            it { is_expected.to be_able_to(:read, task_connection) }
            it { is_expected.not_to be_able_to(:update, task_connection) }
            it { is_expected.to be_able_to(:destroy, task_connection) }
          end
        end

        context "for a task from an invisible project" do
          let(:project) { Fabricate(:invisible_project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when their connection" do
            let(:task_connection) do
              Fabricate(:task_connection, source: task, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, task_connection) }
            it { is_expected.to be_able_to(:read, task_connection) }
            it { is_expected.not_to be_able_to(:update, task_connection) }
            it { is_expected.not_to be_able_to(:destroy, task_connection) }
          end

          context "when someone else's connection" do
            let(:task_connection) do
              Fabricate(:task_connection, source: task)
            end

            it { is_expected.not_to be_able_to(:create, task_connection) }
            it { is_expected.to be_able_to(:read, task_connection) }
            it { is_expected.not_to be_able_to(:update, task_connection) }
            it { is_expected.not_to be_able_to(:destroy, task_connection) }
          end
        end
      end
    end

    %i[worker].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        let(:task_connection) do
          Fabricate(:task_connection, source: task, user: current_user)
        end

        subject(:ability) { Ability.new(current_user) }

        context "for a totally visible task" do
          let(:project) { Fabricate(:project) }
          let(:task) { Fabricate(:task, project: project) }

          it { is_expected.not_to be_able_to(:create, task_connection) }
          it { is_expected.to be_able_to(:read, task_connection) }
          it { is_expected.not_to be_able_to(:update, task_connection) }
          it { is_expected.not_to be_able_to(:destroy, task_connection) }
        end

        context "for a task from an internal project" do
          let(:project) { Fabricate(:internal_project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when their connection" do
            let(:task_connection) do
              Fabricate(:task_connection, source: task, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, task_connection) }
            it { is_expected.to be_able_to(:read, task_connection) }
            it { is_expected.not_to be_able_to(:update, task_connection) }
            it { is_expected.not_to be_able_to(:destroy, task_connection) }
          end
        end

        context "for a task from an invisible project" do
          let(:project) { Fabricate(:invisible_project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when their connection" do
            let(:task_connection) do
              Fabricate(:task_connection, source: task, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, task_connection) }
            it { is_expected.not_to be_able_to(:read, task_connection) }
            it { is_expected.not_to be_able_to(:update, task_connection) }
            it { is_expected.not_to be_able_to(:destroy, task_connection) }
          end
        end
      end
    end

    %i[reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        let(:task_connection) do
          Fabricate(:task_connection, source: task, user: current_user)
        end

        subject(:ability) { Ability.new(current_user) }

        context "for a totally visible task" do
          let(:project) { Fabricate(:project) }
          let(:task) { Fabricate(:task, project: project) }

          it { is_expected.not_to be_able_to(:create, task_connection) }
          it { is_expected.to be_able_to(:read, task_connection) }
          it { is_expected.not_to be_able_to(:update, task_connection) }
          it { is_expected.not_to be_able_to(:destroy, task_connection) }
        end

        context "for a task from an internal project" do
          let(:project) { Fabricate(:internal_project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when their connection" do
            let(:task_connection) do
              Fabricate(:task_connection, source: task, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, task_connection) }
            it { is_expected.not_to be_able_to(:read, task_connection) }
            it { is_expected.not_to be_able_to(:update, task_connection) }
            it { is_expected.not_to be_able_to(:destroy, task_connection) }
          end
        end

        context "for a task from an invisible project" do
          let(:project) { Fabricate(:invisible_project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when their connection" do
            let(:task_connection) do
              Fabricate(:task_connection, source: task, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, task_connection) }
            it { is_expected.not_to be_able_to(:read, task_connection) }
            it { is_expected.not_to be_able_to(:update, task_connection) }
            it { is_expected.not_to be_able_to(:destroy, task_connection) }
          end
        end
      end
    end
  end

  describe "TaskClosure model" do
    %i[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        subject(:ability) { Ability.new(current_user) }

        context "for a totally visible task" do
          let(:category) { Fabricate(:category) }
          let(:project) { Fabricate(:project, category: category) }
          let(:task) { Fabricate(:task, project: project) }

          context "when their closure" do
            let(:task_closure) do
              Fabricate(:task_closure, task: task, user: current_user)
            end

            it { is_expected.to be_able_to(:create, task_closure) }
            it { is_expected.to be_able_to(:read, task_closure) }
            it { is_expected.not_to be_able_to(:update, task_closure) }
            it { is_expected.to be_able_to(:destroy, task_closure) }
          end

          context "when someone else's closure" do
            let(:task_closure) { Fabricate(:task_closure, task: task) }

            it { is_expected.not_to be_able_to(:create, task_closure) }
            it { is_expected.to be_able_to(:read, task_closure) }
            it { is_expected.not_to be_able_to(:update, task_closure) }
            it { is_expected.to be_able_to(:destroy, task_closure) }
          end
        end

        context "for a task from an internal category" do
          let(:category) { Fabricate(:internal_category) }
          let(:project) { Fabricate(:project, category: category) }
          let(:task) { Fabricate(:task, project: project) }

          context "when their closure" do
            let(:task_closure) do
              Fabricate(:task_closure, task: task, user: current_user)
            end

            it { is_expected.to be_able_to(:create, task_closure) }
            it { is_expected.to be_able_to(:read, task_closure) }
            it { is_expected.not_to be_able_to(:update, task_closure) }
            it { is_expected.to be_able_to(:destroy, task_closure) }
          end
        end

        context "for a task from an invisible category" do
          let(:category) { Fabricate(:invisible_category) }
          let(:project) { Fabricate(:project, category: category) }
          let(:task) { Fabricate(:task, project: project) }

          context "when their closure" do
            let(:task_closure) do
              Fabricate(:task_closure, task: task, user: current_user)
            end

            it { is_expected.to be_able_to(:create, task_closure) }
            it { is_expected.to be_able_to(:read, task_closure) }
            it { is_expected.not_to be_able_to(:update, task_closure) }
            it { is_expected.to be_able_to(:destroy, task_closure) }
          end
        end
      end
    end

    %i[reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        subject(:ability) { Ability.new(current_user) }

        context "for a totally visible task" do
          let(:category) { Fabricate(:category) }
          let(:project) { Fabricate(:project, category: category) }

          context "when their task & closure" do
            let(:task) do
              Fabricate(:task, project: project, user: current_user)
            end
            let(:task_closure) do
              Fabricate(:task_closure, task: task, user: current_user)
            end

            it { is_expected.to be_able_to(:create, task_closure) }
            it { is_expected.to be_able_to(:read, task_closure) }
            it { is_expected.not_to be_able_to(:update, task_closure) }
            it { is_expected.not_to be_able_to(:destroy, task_closure) }
          end

          context "when someone else's closure" do
            let(:task) do
              Fabricate(:task, project: project, user: current_user)
            end
            let(:task_closure) { Fabricate(:task_closure, task: task) }

            it { is_expected.not_to be_able_to(:create, task_closure) }
            it { is_expected.to be_able_to(:read, task_closure) }
            it { is_expected.not_to be_able_to(:update, task_closure) }
            it { is_expected.not_to be_able_to(:destroy, task_closure) }
          end

          context "when someone else's task" do
            let(:task) { Fabricate(:task, project: project) }
            let(:task_closure) do
              Fabricate(:task_closure, task: task, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, task_closure) }
            it { is_expected.to be_able_to(:read, task_closure) }
            it { is_expected.not_to be_able_to(:update, task_closure) }
            it { is_expected.not_to be_able_to(:destroy, task_closure) }
          end
        end

        context "for a task from an internal category" do
          let(:category) { Fabricate(:internal_category) }
          let(:project) { Fabricate(:project, category: category) }

          context "when their task & closure" do
            let(:task) do
              Fabricate(:task, project: project, user: current_user)
            end
            let(:task_closure) do
              Fabricate(:task_closure, task: task, user: current_user)
            end

            it { is_expected.to be_able_to(:create, task_closure) }
            it { is_expected.to be_able_to(:read, task_closure) }
            it { is_expected.not_to be_able_to(:update, task_closure) }
            it { is_expected.not_to be_able_to(:destroy, task_closure) }
          end

          context "when someone else's closure" do
            let(:task) do
              Fabricate(:task, project: project, user: current_user)
            end
            let(:task_closure) { Fabricate(:task_closure, task: task) }

            it { is_expected.not_to be_able_to(:create, task_closure) }
            it { is_expected.to be_able_to(:read, task_closure) }
            it { is_expected.not_to be_able_to(:update, task_closure) }
            it { is_expected.not_to be_able_to(:destroy, task_closure) }
          end

          context "when someone else's task" do
            let(:task) { Fabricate(:task, project: project) }
            let(:task_closure) do
              Fabricate(:task_closure, task: task, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, task_closure) }
            it { is_expected.to be_able_to(:read, task_closure) }
            it { is_expected.not_to be_able_to(:update, task_closure) }
            it { is_expected.not_to be_able_to(:destroy, task_closure) }
          end
        end

        context "for a task from an invisible category" do
          let(:category) { Fabricate(:invisible_category) }
          let(:project) { Fabricate(:project, category: category) }

          context "when their task & closure" do
            let(:task) do
              Fabricate(:task, project: project, user: current_user)
            end
            let(:task_closure) do
              Fabricate(:task_closure, task: task, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, task_closure) }
            it { is_expected.to be_able_to(:read, task_closure) }
            it { is_expected.not_to be_able_to(:update, task_closure) }
            it { is_expected.not_to be_able_to(:destroy, task_closure) }
          end

          context "when someone else's closure" do
            let(:task) do
              Fabricate(:task, project: project, user: current_user)
            end
            let(:task_closure) { Fabricate(:task_closure, task: task) }

            it { is_expected.not_to be_able_to(:create, task_closure) }
            it { is_expected.to be_able_to(:read, task_closure) }
            it { is_expected.not_to be_able_to(:update, task_closure) }
            it { is_expected.not_to be_able_to(:destroy, task_closure) }
          end

          context "when someone else's task" do
            let(:task) { Fabricate(:task, project: project) }
            let(:task_closure) do
              Fabricate(:task_closure, task: task, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, task_closure) }
            it { is_expected.to be_able_to(:read, task_closure) }
            it { is_expected.not_to be_able_to(:update, task_closure) }
            it { is_expected.not_to be_able_to(:destroy, task_closure) }
          end
        end
      end
    end

    %i[worker].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        subject(:ability) { Ability.new(current_user) }

        context "for a totally visible task" do
          let(:category) { Fabricate(:category) }
          let(:project) { Fabricate(:project, category: category) }
          let(:task) { Fabricate(:task, project: project) }

          let(:task_closure) do
            Fabricate(:task_closure, task: task, user: current_user)
          end

          it { is_expected.not_to be_able_to(:create, task_closure) }
          it { is_expected.to be_able_to(:read, task_closure) }
          it { is_expected.not_to be_able_to(:update, task_closure) }
          it { is_expected.not_to be_able_to(:destroy, task_closure) }
        end

        context "for a task from an internal category" do
          let(:category) { Fabricate(:internal_category) }
          let(:project) { Fabricate(:project, category: category) }
          let(:task) { Fabricate(:task, project: project) }

          let(:task_closure) do
            Fabricate(:task_closure, task: task, user: current_user)
          end

          it { is_expected.not_to be_able_to(:create, task_closure) }
          it { is_expected.to be_able_to(:read, task_closure) }
          it { is_expected.not_to be_able_to(:update, task_closure) }
          it { is_expected.not_to be_able_to(:destroy, task_closure) }
        end

        context "for a task from an invisible category" do
          let(:category) { Fabricate(:invisible_category) }
          let(:project) { Fabricate(:project, category: category) }
          let(:task) { Fabricate(:task, project: project) }

          let(:task_closure) do
            Fabricate(:task_closure, task: task, user: current_user)
          end

          it { is_expected.not_to be_able_to(:create, task_closure) }
          it { is_expected.not_to be_able_to(:read, task_closure) }
          it { is_expected.not_to be_able_to(:update, task_closure) }
          it { is_expected.not_to be_able_to(:destroy, task_closure) }
        end
      end
    end

    %i[reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        subject(:ability) { Ability.new(current_user) }

        context "for a totally visible task" do
          let(:category) { Fabricate(:category) }
          let(:project) { Fabricate(:project, category: category) }
          let(:task) { Fabricate(:task, project: project) }

          let(:task_closure) do
            Fabricate(:task_closure, task: task, user: current_user)
          end

          it { is_expected.not_to be_able_to(:create, task_closure) }
          it { is_expected.to be_able_to(:read, task_closure) }
          it { is_expected.not_to be_able_to(:update, task_closure) }
          it { is_expected.not_to be_able_to(:destroy, task_closure) }
        end

        context "for a task from an internal category" do
          let(:category) { Fabricate(:internal_category) }
          let(:project) { Fabricate(:project, category: category) }
          let(:task) { Fabricate(:task, project: project) }

          let(:task_closure) do
            Fabricate(:task_closure, task: task, user: current_user)
          end

          it { is_expected.not_to be_able_to(:create, task_closure) }
          it { is_expected.not_to be_able_to(:read, task_closure) }
          it { is_expected.not_to be_able_to(:update, task_closure) }
          it { is_expected.not_to be_able_to(:destroy, task_closure) }
        end

        context "for a task from an invisible category" do
          let(:category) { Fabricate(:invisible_category) }
          let(:project) { Fabricate(:project, category: category) }
          let(:task) { Fabricate(:task, project: project) }

          let(:task_closure) do
            Fabricate(:task_closure, task: task, user: current_user)
          end

          it { is_expected.not_to be_able_to(:create, task_closure) }
          it { is_expected.not_to be_able_to(:read, task_closure) }
          it { is_expected.not_to be_able_to(:update, task_closure) }
          it { is_expected.not_to be_able_to(:destroy, task_closure) }
        end
      end
    end
  end

  describe "TaskReopening model" do
    %i[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        subject(:ability) { Ability.new(current_user) }

        context "for a totally visible task" do
          let(:project) { Fabricate(:project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when their closure" do
            let(:task_reopening) do
              Fabricate(:task_reopening, task: task, user: current_user)
            end

            it { is_expected.to be_able_to(:create, task_reopening) }
            it { is_expected.to be_able_to(:read, task_reopening) }
            it { is_expected.not_to be_able_to(:update, task_reopening) }
            it { is_expected.to be_able_to(:destroy, task_reopening) }
          end

          context "when someone else's reopening" do
            let(:task_reopening) { Fabricate(:task_reopening) }

            it { is_expected.not_to be_able_to(:create, task_reopening) }
            it { is_expected.to be_able_to(:read, task_reopening) }
            it { is_expected.not_to be_able_to(:update, task_reopening) }
            it { is_expected.to be_able_to(:destroy, task_reopening) }
          end
        end

        context "for a task from an internal project" do
          let(:project) { Fabricate(:internal_project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when their closure" do
            let(:task_reopening) do
              Fabricate(:task_reopening, task: task, user: current_user)
            end

            it { is_expected.to be_able_to(:create, task_reopening) }
            it { is_expected.to be_able_to(:read, task_reopening) }
            it { is_expected.not_to be_able_to(:update, task_reopening) }
            it { is_expected.to be_able_to(:destroy, task_reopening) }
          end

          context "when someone else's reopening" do
            let(:task_reopening) { Fabricate(:task_reopening) }

            it { is_expected.not_to be_able_to(:create, task_reopening) }
            it { is_expected.to be_able_to(:read, task_reopening) }
            it { is_expected.not_to be_able_to(:update, task_reopening) }
            it { is_expected.to be_able_to(:destroy, task_reopening) }
          end
        end

        context "for a task from an invisible project" do
          let(:project) { Fabricate(:invisible_project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when their closure" do
            let(:task_reopening) do
              Fabricate(:task_reopening, task: task, user: current_user)
            end

            it { is_expected.to be_able_to(:create, task_reopening) }
            it { is_expected.to be_able_to(:read, task_reopening) }
            it { is_expected.not_to be_able_to(:update, task_reopening) }
            it { is_expected.to be_able_to(:destroy, task_reopening) }
          end

          context "when someone else's reopening" do
            let(:task_reopening) { Fabricate(:task_reopening) }

            it { is_expected.not_to be_able_to(:create, task_reopening) }
            it { is_expected.to be_able_to(:read, task_reopening) }
            it { is_expected.not_to be_able_to(:update, task_reopening) }
            it { is_expected.to be_able_to(:destroy, task_reopening) }
          end
        end
      end
    end

    %i[reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        subject(:ability) { Ability.new(current_user) }

        context "for a totally visible task" do
          let(:project) { Fabricate(:project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when their reopening" do
            let(:task_reopening) do
              Fabricate(:task_reopening, task: task, user: current_user)
            end

            it { is_expected.to be_able_to(:create, task_reopening) }
            it { is_expected.to be_able_to(:read, task_reopening) }
            it { is_expected.not_to be_able_to(:update, task_reopening) }
            it { is_expected.not_to be_able_to(:destroy, task_reopening) }
          end

          context "when someone else's reopening" do
            let(:task_reopening) { Fabricate(:task_reopening) }

            it { is_expected.not_to be_able_to(:create, task_reopening) }
            it { is_expected.to be_able_to(:read, task_reopening) }
            it { is_expected.not_to be_able_to(:update, task_reopening) }
            it { is_expected.not_to be_able_to(:destroy, task_reopening) }
          end
        end

        context "for a task from an internal project" do
          let(:project) { Fabricate(:internal_project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when their closure" do
            let(:task_reopening) do
              Fabricate(:task_reopening, task: task, user: current_user)
            end

            it { is_expected.to be_able_to(:create, task_reopening) }
            it { is_expected.to be_able_to(:read, task_reopening) }
            it { is_expected.not_to be_able_to(:update, task_reopening) }
            it { is_expected.not_to be_able_to(:destroy, task_reopening) }
          end

          context "when someone else's reopening" do
            let(:task_reopening) { Fabricate(:task_reopening) }

            it { is_expected.not_to be_able_to(:create, task_reopening) }
            it { is_expected.to be_able_to(:read, task_reopening) }
            it { is_expected.not_to be_able_to(:update, task_reopening) }
            it { is_expected.not_to be_able_to(:destroy, task_reopening) }
          end
        end

        context "for a task from an invisible project" do
          let(:project) { Fabricate(:invisible_project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when their closure" do
            let(:task_reopening) do
              Fabricate(:task_reopening, task: task, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, task_reopening) }
            it { is_expected.to be_able_to(:read, task_reopening) }
            it { is_expected.not_to be_able_to(:update, task_reopening) }
            it { is_expected.not_to be_able_to(:destroy, task_reopening) }
          end

          context "when someone else's reopening" do
            let(:task_reopening) { Fabricate(:task_reopening) }

            it { is_expected.not_to be_able_to(:create, task_reopening) }
            it { is_expected.to be_able_to(:read, task_reopening) }
            it { is_expected.not_to be_able_to(:update, task_reopening) }
            it { is_expected.not_to be_able_to(:destroy, task_reopening) }
          end
        end
      end
    end

    %i[worker].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        let(:task_reopening) do
          Fabricate(:task_reopening, task: task, user: current_user)
        end

        subject(:ability) { Ability.new(current_user) }

        context "for a totally visible task" do
          let(:project) { Fabricate(:project) }
          let(:task) { Fabricate(:task, project: project) }

          it { is_expected.not_to be_able_to(:create, task_reopening) }
          it { is_expected.to be_able_to(:read, task_reopening) }
          it { is_expected.not_to be_able_to(:update, task_reopening) }
          it { is_expected.not_to be_able_to(:destroy, task_reopening) }
        end

        context "for a task from an internal project" do
          let(:project) { Fabricate(:internal_project) }
          let(:task) { Fabricate(:task, project: project) }

          it { is_expected.not_to be_able_to(:create, task_reopening) }
          it { is_expected.to be_able_to(:read, task_reopening) }
          it { is_expected.not_to be_able_to(:update, task_reopening) }
          it { is_expected.not_to be_able_to(:destroy, task_reopening) }
        end

        context "for a task from an invisible project" do
          let(:project) { Fabricate(:invisible_project) }
          let(:task) { Fabricate(:task, project: project) }

          it { is_expected.not_to be_able_to(:create, task_reopening) }
          it { is_expected.not_to be_able_to(:read, task_reopening) }
          it { is_expected.not_to be_able_to(:update, task_reopening) }
          it { is_expected.not_to be_able_to(:destroy, task_reopening) }
        end
      end
    end

    %i[reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        let(:task_reopening) do
          Fabricate(:task_reopening, task: task, user: current_user)
        end

        subject(:ability) { Ability.new(current_user) }

        context "for a totally visible task" do
          let(:project) { Fabricate(:project) }
          let(:task) { Fabricate(:task, project: project) }

          it { is_expected.not_to be_able_to(:create, task_reopening) }
          it { is_expected.to be_able_to(:read, task_reopening) }
          it { is_expected.not_to be_able_to(:update, task_reopening) }
          it { is_expected.not_to be_able_to(:destroy, task_reopening) }
        end

        context "for a task from an internal project" do
          let(:project) { Fabricate(:internal_project) }
          let(:task) { Fabricate(:task, project: project) }

          it { is_expected.not_to be_able_to(:create, task_reopening) }
          it { is_expected.not_to be_able_to(:read, task_reopening) }
          it { is_expected.not_to be_able_to(:update, task_reopening) }
          it { is_expected.not_to be_able_to(:destroy, task_reopening) }
        end

        context "for a task from an invisible project" do
          let(:project) { Fabricate(:invisible_project) }
          let(:task) { Fabricate(:task, project: project) }

          it { is_expected.not_to be_able_to(:create, task_reopening) }
          it { is_expected.not_to be_able_to(:read, task_reopening) }
          it { is_expected.not_to be_able_to(:update, task_reopening) }
          it { is_expected.not_to be_able_to(:destroy, task_reopening) }
        end
      end
    end
  end

  describe "TaskSubscription model" do
    %i[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        context "for a totally visible task" do
          let(:project) { Fabricate(:project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when belongs to them" do
            let(:task_subscription) do
              Fabricate(:task_subscription, task: task, user: current_user)
            end

            it { is_expected.to be_able_to(:create, task_subscription) }
            it { is_expected.to be_able_to(:read, task_subscription) }
            it { is_expected.to be_able_to(:update, task_subscription) }
            it { is_expected.to be_able_to(:destroy, task_subscription) }
          end

          context "when doesn't belong to them" do
            let(:task_subscription) do
              Fabricate(:task_subscription, task: task)
            end

            it { is_expected.not_to be_able_to(:create, task_subscription) }
            it { is_expected.not_to be_able_to(:read, task_subscription) }
            it { is_expected.not_to be_able_to(:update, task_subscription) }
            it { is_expected.not_to be_able_to(:destroy, task_subscription) }
          end
        end

        context "for a task from an internal project" do
          let(:project) { Fabricate(:internal_project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when belongs to them" do
            let(:task_subscription) do
              Fabricate(:task_subscription, task: task, user: current_user)
            end

            it { is_expected.to be_able_to(:create, task_subscription) }
            it { is_expected.to be_able_to(:read, task_subscription) }
            it { is_expected.to be_able_to(:update, task_subscription) }
            it { is_expected.to be_able_to(:destroy, task_subscription) }
          end
        end

        context "for a task from an invisible project" do
          let(:project) { Fabricate(:invisible_project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when belongs to them" do
            let(:task_subscription) do
              Fabricate(:task_subscription, task: task, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, task_subscription) }
            it { is_expected.not_to be_able_to(:read, task_subscription) }
            it { is_expected.not_to be_able_to(:update, task_subscription) }
            it { is_expected.not_to be_able_to(:destroy, task_subscription) }
          end
        end
      end
    end

    %i[worker].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        context "for a totally visible task" do
          let(:project) { Fabricate(:project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when belongs to them" do
            let(:task_subscription) do
              Fabricate(:task_subscription, task: task, user: current_user)
            end

            it { is_expected.to be_able_to(:create, task_subscription) }
            it { is_expected.to be_able_to(:read, task_subscription) }
            it { is_expected.to be_able_to(:update, task_subscription) }
            it { is_expected.to be_able_to(:destroy, task_subscription) }
          end

          context "when doesn't belong to them" do
            let(:task_subscription) do
              Fabricate(:task_subscription, task: task)
            end

            it { is_expected.not_to be_able_to(:create, task_subscription) }
            it { is_expected.not_to be_able_to(:read, task_subscription) }
            it { is_expected.not_to be_able_to(:update, task_subscription) }
            it { is_expected.not_to be_able_to(:destroy, task_subscription) }
          end
        end

        context "for a task from an internal project" do
          let(:project) { Fabricate(:internal_project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when belongs to them" do
            let(:task_subscription) do
              Fabricate(:task_subscription, task: task, user: current_user)
            end

            it { is_expected.to be_able_to(:create, task_subscription) }
            it { is_expected.to be_able_to(:read, task_subscription) }
            it { is_expected.to be_able_to(:update, task_subscription) }
            it { is_expected.to be_able_to(:destroy, task_subscription) }
          end
        end

        context "for a task from an invisible project" do
          let(:project) { Fabricate(:invisible_project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when belongs to them" do
            let(:task_subscription) do
              Fabricate(:task_subscription, task: task, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, task_subscription) }
            it { is_expected.not_to be_able_to(:read, task_subscription) }
            it { is_expected.not_to be_able_to(:update, task_subscription) }
            it { is_expected.not_to be_able_to(:destroy, task_subscription) }
          end
        end
      end
    end

    %i[reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        context "for a totally visible task" do
          let(:project) { Fabricate(:project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when belongs to them" do
            let(:task_subscription) do
              Fabricate(:task_subscription, task: task, user: current_user)
            end

            it { is_expected.to be_able_to(:create, task_subscription) }
            it { is_expected.to be_able_to(:read, task_subscription) }
            it { is_expected.to be_able_to(:update, task_subscription) }
            it { is_expected.to be_able_to(:destroy, task_subscription) }
          end

          context "when doesn't belong to them" do
            let(:task_subscription) do
              Fabricate(:task_subscription, task: task)
            end

            it { is_expected.not_to be_able_to(:create, task_subscription) }
            it { is_expected.not_to be_able_to(:read, task_subscription) }
            it { is_expected.not_to be_able_to(:update, task_subscription) }
            it { is_expected.not_to be_able_to(:destroy, task_subscription) }
          end
        end

        context "for a task from an internal project" do
          let(:project) { Fabricate(:internal_project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when belongs to them" do
            let(:task_subscription) do
              Fabricate(:task_subscription, task: task, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, task_subscription) }
            it { is_expected.not_to be_able_to(:read, task_subscription) }
            it { is_expected.not_to be_able_to(:update, task_subscription) }
            it { is_expected.not_to be_able_to(:destroy, task_subscription) }
          end
        end

        context "for a task from an invisible project" do
          let(:project) { Fabricate(:invisible_project) }
          let(:task) { Fabricate(:task, project: project) }

          context "when belongs to them" do
            let(:task_subscription) do
              Fabricate(:task_subscription, task: task, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, task_subscription) }
            it { is_expected.not_to be_able_to(:read, task_subscription) }
            it { is_expected.not_to be_able_to(:update, task_subscription) }
            it { is_expected.not_to be_able_to(:destroy, task_subscription) }
          end
        end
      end
    end
  end

  describe "TaskType model" do
    let(:task_type) { Fabricate(:task_type) }

    %i[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        it { is_expected.to be_able_to(:create, task_type) }
        it { is_expected.to be_able_to(:read, task_type) }
        it { is_expected.to be_able_to(:update, task_type) }
        it { is_expected.to be_able_to(:destroy, task_type) }
      end
    end

    %i[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        it { is_expected.not_to be_able_to(:create, task_type) }
        it { is_expected.not_to be_able_to(:read, task_type) }
        it { is_expected.not_to be_able_to(:update, task_type) }
        it { is_expected.not_to be_able_to(:destroy, task_type) }
      end
    end
  end
end
