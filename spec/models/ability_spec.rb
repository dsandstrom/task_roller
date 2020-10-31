# frozen_string_literal: true

require "rails_helper"
require "cancan/matchers"

RSpec.describe Ability do
  describe "Category model" do
    let(:category) { Fabricate(:category) }

    describe "for an admin" do
      let(:admin) { Fabricate(:user_admin) }
      subject(:ability) { Ability.new(admin) }

      it { is_expected.to be_able_to(:create, category) }
      it { is_expected.to be_able_to(:read, category) }
      it { is_expected.to be_able_to(:update, category) }
      it { is_expected.to be_able_to(:destroy, category) }
    end

    %i[reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }
        subject(:ability) { Ability.new(current_user) }

        it { is_expected.not_to be_able_to(:create, category) }
        it { is_expected.to be_able_to(:read, category) }
        it { is_expected.to be_able_to(:update, category) }
        it { is_expected.not_to be_able_to(:destroy, category) }
      end
    end

    %i[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }
        subject(:ability) { Ability.new(current_user) }

        it { is_expected.not_to be_able_to(:create, category) }
        it { is_expected.to be_able_to(:read, category) }
        it { is_expected.not_to be_able_to(:update, category) }
        it { is_expected.not_to be_able_to(:destroy, category) }
      end
    end
  end

  describe "Issue model" do
    describe "for an admin" do
      let(:admin) { Fabricate(:user_admin) }
      subject(:ability) { Ability.new(admin) }

      context "when belongs to them" do
        let(:issue) { Fabricate(:issue, user: admin) }

        it { is_expected.to be_able_to(:create, issue) }
        it { is_expected.to be_able_to(:read, issue) }
        it { is_expected.to be_able_to(:update, issue) }
        it { is_expected.to be_able_to(:destroy, issue) }
        it { is_expected.to be_able_to(:open, issue) }
        it { is_expected.to be_able_to(:close, issue) }
      end

      context "when doesn't belong to them" do
        let(:issue) { Fabricate(:issue) }

        it { is_expected.not_to be_able_to(:create, issue) }
        it { is_expected.to be_able_to(:read, issue) }
        it { is_expected.to be_able_to(:update, issue) }
        it { is_expected.to be_able_to(:destroy, issue) }
        it { is_expected.to be_able_to(:open, issue) }
        it { is_expected.to be_able_to(:close, issue) }
      end
    end

    %i[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }
        subject(:ability) { Ability.new(current_user) }

        context "when belongs to them" do
          let(:issue) { Fabricate(:issue, user: current_user) }

          it { is_expected.to be_able_to(:create, issue) }
          it { is_expected.to be_able_to(:read, issue) }
          it { is_expected.to be_able_to(:update, issue) }
          it { is_expected.not_to be_able_to(:destroy, issue) }
          it { is_expected.not_to be_able_to(:open, issue) }
          it { is_expected.not_to be_able_to(:close, issue) }
        end

        context "when doesn't belong to them" do
          let(:issue) { Fabricate(:issue) }

          it { is_expected.not_to be_able_to(:create, issue) }
          it { is_expected.to be_able_to(:read, issue) }
          it { is_expected.not_to be_able_to(:update, issue) }
          it { is_expected.not_to be_able_to(:destroy, issue) }
          it { is_expected.not_to be_able_to(:open, issue) }
          it { is_expected.not_to be_able_to(:close, issue) }
        end
      end
    end
  end

  describe "IssueSubscription model" do
    describe "for an admin" do
      let(:admin) { Fabricate(:user_admin) }
      subject(:ability) { Ability.new(admin) }

      context "when belongs to them" do
        let(:issue_subscription) { Fabricate(:issue_subscription, user: admin) }

        it { is_expected.to be_able_to(:create, issue_subscription) }
        it { is_expected.to be_able_to(:read, issue_subscription) }
        it { is_expected.to be_able_to(:update, issue_subscription) }
        it { is_expected.to be_able_to(:destroy, issue_subscription) }
      end

      context "when doesn't belong to them" do
        let(:issue_subscription) { Fabricate(:issue_subscription) }

        it { is_expected.not_to be_able_to(:create, issue_subscription) }
        it { is_expected.not_to be_able_to(:read, issue_subscription) }
        it { is_expected.not_to be_able_to(:update, issue_subscription) }
        it { is_expected.not_to be_able_to(:destroy, issue_subscription) }
      end
    end

    %i[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }
        subject(:ability) { Ability.new(current_user) }

        context "when belongs to them" do
          let(:issue_subscription) do
            Fabricate(:issue_subscription, user: current_user)
          end

          it { is_expected.to be_able_to(:create, issue_subscription) }
          it { is_expected.to be_able_to(:read, issue_subscription) }
          it { is_expected.to be_able_to(:update, issue_subscription) }
          it { is_expected.to be_able_to(:destroy, issue_subscription) }
        end

        context "when doesn't belong to them" do
          let(:issue_subscription) { Fabricate(:issue_subscription) }

          it { is_expected.not_to be_able_to(:create, issue_subscription) }
          it { is_expected.not_to be_able_to(:read, issue_subscription) }
          it { is_expected.not_to be_able_to(:update, issue_subscription) }
          it { is_expected.not_to be_able_to(:destroy, issue_subscription) }
        end
      end
    end
  end

  describe "TaskSubscription model" do
    describe "for an admin" do
      let(:admin) { Fabricate(:user_admin) }
      subject(:ability) { Ability.new(admin) }

      context "when belongs to them" do
        let(:task_subscription) { Fabricate(:task_subscription, user: admin) }

        it { is_expected.to be_able_to(:create, task_subscription) }
        it { is_expected.to be_able_to(:read, task_subscription) }
        it { is_expected.to be_able_to(:update, task_subscription) }
        it { is_expected.to be_able_to(:destroy, task_subscription) }
      end

      context "when doesn't belong to them" do
        let(:task_subscription) { Fabricate(:task_subscription) }

        it { is_expected.not_to be_able_to(:create, task_subscription) }
        it { is_expected.not_to be_able_to(:read, task_subscription) }
        it { is_expected.not_to be_able_to(:update, task_subscription) }
        it { is_expected.not_to be_able_to(:destroy, task_subscription) }
      end
    end

    %i[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }
        subject(:ability) { Ability.new(current_user) }

        context "when belongs to them" do
          let(:task_subscription) do
            Fabricate(:task_subscription, user: current_user)
          end

          it { is_expected.to be_able_to(:create, task_subscription) }
          it { is_expected.to be_able_to(:read, task_subscription) }
          it { is_expected.to be_able_to(:update, task_subscription) }
          it { is_expected.to be_able_to(:destroy, task_subscription) }
        end

        context "when doesn't belong to them" do
          let(:task_subscription) { Fabricate(:task_subscription) }

          it { is_expected.not_to be_able_to(:create, task_subscription) }
          it { is_expected.not_to be_able_to(:read, task_subscription) }
          it { is_expected.not_to be_able_to(:update, task_subscription) }
          it { is_expected.not_to be_able_to(:destroy, task_subscription) }
        end
      end
    end
  end

  describe "IssueType model" do
    let(:issue_type) { Fabricate(:issue_type) }

    %i[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }
        subject(:ability) { Ability.new(current_user) }

        it { is_expected.to be_able_to(:create, issue_type) }
        it { is_expected.to be_able_to(:read, issue_type) }
        it { is_expected.to be_able_to(:update, issue_type) }
        it { is_expected.to be_able_to(:destroy, issue_type) }
      end
    end

    %i[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }
        subject(:ability) { Ability.new(current_user) }

        it { is_expected.not_to be_able_to(:create, issue_type) }
        it { is_expected.not_to be_able_to(:read, issue_type) }
        it { is_expected.not_to be_able_to(:update, issue_type) }
        it { is_expected.not_to be_able_to(:destroy, issue_type) }
      end
    end
  end

  describe "Progression model" do
    let(:task) { Fabricate(:task) }

    describe "for an admin" do
      let(:admin) { Fabricate(:user_admin) }
      subject(:ability) { Ability.new(admin) }

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
        let(:progression) { Fabricate(:progression, user: admin) }

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

      context "when no task" do
        let(:progression) { Fabricate(:progression, task: task, user: admin) }

        before do
          task.assignees << admin
          progression.update_attribute :task_id, 0
        end

        it { is_expected.not_to be_able_to(:create, progression) }
      end
    end

    %i[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }
        subject(:ability) { Ability.new(current_user) }

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
          let(:progression) { Fabricate(:progression, user: current_user) }

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
    end
  end

  describe "Project model" do
    let(:project) { Fabricate(:project) }

    describe "for an admin" do
      let(:admin) { Fabricate(:user_admin) }
      subject(:ability) { Ability.new(admin) }

      it { is_expected.to be_able_to(:create, project) }
      it { is_expected.to be_able_to(:read, project) }
      it { is_expected.to be_able_to(:update, project) }
      it { is_expected.to be_able_to(:destroy, project) }
    end

    %i[reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }
        subject(:ability) { Ability.new(current_user) }

        it { is_expected.to be_able_to(:create, project) }
        it { is_expected.to be_able_to(:read, project) }
        it { is_expected.to be_able_to(:update, project) }
        it { is_expected.not_to be_able_to(:destroy, project) }
      end
    end

    %i[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }
        subject(:ability) { Ability.new(current_user) }

        it { is_expected.not_to be_able_to(:create, project) }
        it { is_expected.to be_able_to(:read, project) }
        it { is_expected.not_to be_able_to(:update, project) }
        it { is_expected.not_to be_able_to(:destroy, project) }
      end
    end
  end

  describe "Resolution model" do
    describe "for an admin" do
      let(:admin) { Fabricate(:user_admin) }
      subject(:ability) { Ability.new(admin) }

      context "when resolution/issue belong to them" do
        let(:issue) { Fabricate(:issue, user: admin) }
        let(:resolution) { Fabricate(:resolution, issue: issue, user: admin) }

        it { is_expected.to be_able_to(:create, resolution) }
        it { is_expected.to be_able_to(:read, resolution) }
        it { is_expected.to be_able_to(:update, resolution) }
        it { is_expected.to be_able_to(:destroy, resolution) }
      end

      context "when issue doesn't belong to them" do
        let(:issue) { Fabricate(:issue) }
        let(:resolution) { Fabricate(:resolution, issue: issue, user: admin) }

        it { is_expected.not_to be_able_to(:create, resolution) }
        it { is_expected.to be_able_to(:read, resolution) }
        it { is_expected.to be_able_to(:update, resolution) }
        it { is_expected.to be_able_to(:destroy, resolution) }
      end

      context "when resolution doesn't belong to them" do
        let(:issue) { Fabricate(:issue, user: admin) }
        let(:resolution) { Fabricate(:resolution, issue: issue) }

        it { is_expected.not_to be_able_to(:create, resolution) }
        it { is_expected.to be_able_to(:read, resolution) }
        it { is_expected.to be_able_to(:update, resolution) }
        it { is_expected.to be_able_to(:destroy, resolution) }
      end
    end

    %i[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }
        subject(:ability) { Ability.new(current_user) }

        context "when resolution/issue belong to them" do
          let(:issue) { Fabricate(:issue, user: current_user) }
          let(:resolution) do
            Fabricate(:resolution, issue: issue, user: current_user)
          end

          it { is_expected.to be_able_to(:create, resolution) }
          it { is_expected.to be_able_to(:read, resolution) }
          it { is_expected.not_to be_able_to(:update, resolution) }
          it { is_expected.not_to be_able_to(:destroy, resolution) }
        end

        context "when resolution doesn't belong to them" do
          let(:issue) { Fabricate(:issue, user: current_user) }
          let(:resolution) { Fabricate(:resolution, issue: issue) }

          it { is_expected.not_to be_able_to(:create, resolution) }
          it { is_expected.to be_able_to(:read, resolution) }
          it { is_expected.not_to be_able_to(:update, resolution) }
          it { is_expected.not_to be_able_to(:destroy, resolution) }
        end

        context "when issue doesn't belong to them" do
          let(:issue) { Fabricate(:issue) }
          let(:resolution) { Fabricate(:resolution, issue: issue) }

          it { is_expected.not_to be_able_to(:create, resolution) }
          it { is_expected.to be_able_to(:read, resolution) }
          it { is_expected.not_to be_able_to(:update, resolution) }
          it { is_expected.not_to be_able_to(:destroy, resolution) }
        end
      end
    end
  end

  describe "Review model" do
    let(:task) { Fabricate(:task) }

    describe "for an admin" do
      let(:admin) { Fabricate(:user_admin) }
      subject(:ability) { Ability.new(admin) }

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
        let(:review) { Fabricate(:disapproved_review, task: task, user: admin) }

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

    %i[reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }
        subject(:ability) { Ability.new(current_user) }

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
            let(:review) { Fabricate(:review, task: task, user: current_user) }

            it { is_expected.to be_able_to(:destroy, review) }
          end

          context "and task is closed" do
            let(:task) { Fabricate(:closed_task) }
            let(:review) { Fabricate(:review, task: task, user: current_user) }

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
    end

    %i[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }
        subject(:ability) { Ability.new(current_user) }

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
    end
  end

  describe "RollerType model" do
    let(:roller_type) { RollerType }

    %i[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }
        subject(:ability) { Ability.new(current_user) }

        it { is_expected.not_to be_able_to(:create, roller_type) }
        it { is_expected.to be_able_to(:read, roller_type) }
        it { is_expected.not_to be_able_to(:update, roller_type) }
        it { is_expected.not_to be_able_to(:destroy, roller_type) }
      end
    end

    %i[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }
        subject(:ability) { Ability.new(current_user) }

        it { is_expected.not_to be_able_to(:create, roller_type) }
        it { is_expected.not_to be_able_to(:read, roller_type) }
        it { is_expected.not_to be_able_to(:update, roller_type) }
        it { is_expected.not_to be_able_to(:destroy, roller_type) }
      end
    end
  end

  describe "Task model" do
    describe "for an admin" do
      let(:admin) { Fabricate(:user_admin) }
      subject(:ability) { Ability.new(admin) }

      context "when belongs to them" do
        let(:task) { Fabricate(:task, user: admin) }

        it { is_expected.to be_able_to(:create, task) }
        it { is_expected.to be_able_to(:read, task) }
        it { is_expected.to be_able_to(:update, task) }
        it { is_expected.to be_able_to(:destroy, task) }
        it { is_expected.to be_able_to(:assign, task) }
        it { is_expected.to be_able_to(:open, task) }
        it { is_expected.to be_able_to(:close, task) }
      end

      context "when doesn't belong to them" do
        let(:task) { Fabricate(:task) }

        it { is_expected.not_to be_able_to(:create, task) }
        it { is_expected.to be_able_to(:read, task) }
        it { is_expected.to be_able_to(:update, task) }
        it { is_expected.to be_able_to(:destroy, task) }
        it { is_expected.to be_able_to(:assign, task) }
        it { is_expected.to be_able_to(:open, task) }
        it { is_expected.to be_able_to(:close, task) }
      end
    end

    %i[reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }
        subject(:ability) { Ability.new(current_user) }

        context "when belongs to them" do
          let(:task) { Fabricate(:task, user: current_user) }

          it { is_expected.to be_able_to(:create, task) }
          it { is_expected.to be_able_to(:read, task) }
          it { is_expected.to be_able_to(:update, task) }
          it { is_expected.not_to be_able_to(:destroy, task) }
          it { is_expected.to be_able_to(:assign, task) }
          it { is_expected.not_to be_able_to(:open, task) }
          it { is_expected.not_to be_able_to(:close, task) }
        end

        context "when doesn't belong to them" do
          let(:task) { Fabricate(:task) }

          it { is_expected.not_to be_able_to(:create, task) }
          it { is_expected.to be_able_to(:read, task) }
          it { is_expected.not_to be_able_to(:update, task) }
          it { is_expected.not_to be_able_to(:destroy, task) }
          it { is_expected.to be_able_to(:assign, task) }
          it { is_expected.not_to be_able_to(:open, task) }
          it { is_expected.not_to be_able_to(:close, task) }
        end
      end
    end

    %i[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }
        subject(:ability) { Ability.new(current_user) }

        context "when belongs to them" do
          let(:task) { Fabricate(:task, user: current_user) }

          it { is_expected.not_to be_able_to(:create, task) }
          it { is_expected.to be_able_to(:read, task) }
          it { is_expected.to be_able_to(:update, task) }
          it { is_expected.not_to be_able_to(:destroy, task) }
          it { is_expected.not_to be_able_to(:assign, task) }
          it { is_expected.not_to be_able_to(:open, task) }
          it { is_expected.not_to be_able_to(:close, task) }
        end

        context "when doesn't belong to them" do
          let(:task) { Fabricate(:task) }

          it { is_expected.not_to be_able_to(:create, task) }
          it { is_expected.to be_able_to(:read, task) }
          it { is_expected.not_to be_able_to(:update, task) }
          it { is_expected.not_to be_able_to(:destroy, task) }
          it { is_expected.not_to be_able_to(:assign, task) }
          it { is_expected.not_to be_able_to(:open, task) }
          it { is_expected.not_to be_able_to(:close, task) }
        end
      end
    end
  end

  describe "TaskComment model" do
    describe "for an admin" do
      let(:admin) { Fabricate(:user_admin) }
      subject(:ability) { Ability.new(admin) }

      context "when belongs to them" do
        let(:task_comment) { Fabricate(:task_comment, user: admin) }

        it { is_expected.to be_able_to(:create, task_comment) }
        it { is_expected.to be_able_to(:read, task_comment) }
        it { is_expected.to be_able_to(:update, task_comment) }
        it { is_expected.to be_able_to(:destroy, task_comment) }
      end

      context "when doesn't belong to them" do
        let(:task_comment) { Fabricate(:task_comment) }

        it { is_expected.not_to be_able_to(:create, task_comment) }
        it { is_expected.to be_able_to(:read, task_comment) }
        it { is_expected.to be_able_to(:update, task_comment) }
        it { is_expected.to be_able_to(:destroy, task_comment) }
      end
    end

    %i[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }
        subject(:ability) { Ability.new(current_user) }

        context "when belongs to them" do
          let(:task_comment) { Fabricate(:task_comment, user: current_user) }

          it { is_expected.to be_able_to(:create, task_comment) }
          it { is_expected.to be_able_to(:read, task_comment) }
          it { is_expected.to be_able_to(:update, task_comment) }
          it { is_expected.not_to be_able_to(:destroy, task_comment) }
        end

        context "when doesn't belong to them" do
          let(:task_comment) { Fabricate(:task_comment) }

          it { is_expected.not_to be_able_to(:create, task_comment) }
          it { is_expected.to be_able_to(:read, task_comment) }
          it { is_expected.not_to be_able_to(:update, task_comment) }
          it { is_expected.not_to be_able_to(:destroy, task_comment) }
        end
      end
    end
  end

  describe "TaskConnection model" do
    let(:task_connection) { Fabricate(:task_connection) }

    %i[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }
        subject(:ability) { Ability.new(current_user) }

        it { is_expected.to be_able_to(:create, task_connection) }
        it { is_expected.to be_able_to(:read, task_connection) }
        it { is_expected.to be_able_to(:update, task_connection) }
        it { is_expected.to be_able_to(:destroy, task_connection) }
      end
    end

    %i[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }
        subject(:ability) { Ability.new(current_user) }

        it { is_expected.not_to be_able_to(:create, task_connection) }
        it { is_expected.to be_able_to(:read, task_connection) }
        it { is_expected.not_to be_able_to(:update, task_connection) }
        it { is_expected.not_to be_able_to(:destroy, task_connection) }
      end
    end
  end

  describe "TaskType model" do
    let(:task_type) { Fabricate(:task_type) }

    %i[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }
        subject(:ability) { Ability.new(current_user) }

        it { is_expected.to be_able_to(:create, task_type) }
        it { is_expected.to be_able_to(:read, task_type) }
        it { is_expected.to be_able_to(:update, task_type) }
        it { is_expected.to be_able_to(:destroy, task_type) }
      end
    end

    %i[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }
        subject(:ability) { Ability.new(current_user) }

        it { is_expected.not_to be_able_to(:create, task_type) }
        it { is_expected.not_to be_able_to(:read, task_type) }
        it { is_expected.not_to be_able_to(:update, task_type) }
        it { is_expected.not_to be_able_to(:destroy, task_type) }
      end
    end
  end

  describe "User model" do
    let(:random_user) { Fabricate(:user_reviewer) }

    describe "for an admin" do
      let(:admin) { Fabricate(:user_admin) }
      subject(:ability) { Ability.new(admin) }

      context "when another user" do
        it { is_expected.to be_able_to(:create, random_user) }
        it { is_expected.to be_able_to(:read, random_user) }
        it { is_expected.to be_able_to(:update, random_user) }
        it { is_expected.to be_able_to(:destroy, random_user) }
      end

      context "when themselves" do
        it { is_expected.to be_able_to(:create, admin) }
        it { is_expected.to be_able_to(:read, admin) }
        it { is_expected.to be_able_to(:update, admin) }
        it { is_expected.not_to be_able_to(:destroy, admin) }
      end
    end

    %i[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }
        subject(:ability) { Ability.new(current_user) }

        context "when another user" do
          it { is_expected.not_to be_able_to(:create, random_user) }
          it { is_expected.to be_able_to(:read, random_user) }
          it { is_expected.not_to be_able_to(:update, random_user) }
          it { is_expected.not_to be_able_to(:destroy, random_user) }
        end

        context "when themselves" do
          it { is_expected.not_to be_able_to(:create, current_user) }
          it { is_expected.to be_able_to(:read, current_user) }
          it { is_expected.to be_able_to(:update, current_user) }
          it { is_expected.not_to be_able_to(:destroy, current_user) }
        end
      end
    end
  end
end