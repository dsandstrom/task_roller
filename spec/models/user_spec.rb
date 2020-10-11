# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  before do
    @user = User.new(name: "User Name", email: "test@example.com",
                     employee_type: "Worker")
  end

  subject { @user }

  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:email) }
  it { is_expected.to respond_to(:employee_type) }

  it { is_expected.to have_many(:task_assignees) }
  it { is_expected.to have_many(:assignments) }
  it { is_expected.to have_many(:progressions) }

  it { is_expected.to be_valid }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_uniqueness_of(:email).case_insensitive }

  describe "on create" do
    %w[Reporter Reviewer Worker Admin].each do |employee_type|
      context "for a valid employee_type" do
        before { subject.employee_type = employee_type }

        it { is_expected.to be_valid }
      end
    end

    context "for an invalid employee_type" do
      before { subject.employee_type = "something else" }

      it { is_expected.not_to be_valid }
    end
  end

  describe "on update" do
    let(:user) { Fabricate(:user) }

    context "when employee_type is nil" do
      before { user.employee_type = nil }

      it { expect(user).to be_valid }
    end

    context "when employee_type is something else" do
      before { user.employee_type = "something else" }

      it { expect(user).not_to be_valid }
    end
  end

  # CLASS

  describe ".employees" do
    context "when no type specifed" do
      it "includes admins" do
        employee = Fabricate(:user_admin)
        expect(User.employees).to eq([employee])
      end

      it "includes reporters" do
        employee = Fabricate(:user_reporter)
        expect(User.employees).to eq([employee])
      end

      it "includes reviewers" do
        employee = Fabricate(:user_reviewer)
        expect(User.employees).to eq([employee])
      end

      it "includes workers" do
        employee = Fabricate(:user_worker)
        expect(User.employees).to eq([employee])
      end
    end

    context "when given 'Admin'" do
      let(:type) { "Admin" }

      it "includes only Admins" do
        employee = Fabricate(:user_admin)
        Fabricate(:user_reporter)
        Fabricate(:user_reviewer)
        Fabricate(:user_worker)

        expect(User.employees(type)).to eq([employee])
      end
    end

    context "when given 'Reporter'" do
      let(:type) { "Reporter" }

      it "includes only Reporters" do
        employee = Fabricate(:user_reporter)
        Fabricate(:user_admin)
        Fabricate(:user_reviewer)
        Fabricate(:user_worker)

        expect(User.employees(type)).to eq([employee])
      end
    end

    context "when given 'Reviewer'" do
      let(:type) { "Reviewer" }

      it "includes only Reviewers" do
        employee = Fabricate(:user_reviewer)
        Fabricate(:user_admin)
        Fabricate(:user_reporter)
        Fabricate(:user_worker)

        expect(User.employees(type)).to eq([employee])
      end
    end

    context "when given 'Worker'" do
      let(:type) { "Worker" }

      it "includes only Workers" do
        employee = Fabricate(:user_worker)
        Fabricate(:user_admin)
        Fabricate(:user_reporter)
        Fabricate(:user_reviewer)

        expect(User.employees(type)).to eq([employee])
      end
    end
  end

  describe ".admins" do
    it "includes only Admins" do
      user_admin = Fabricate(:user_admin)
      Fabricate(:user_reporter)
      Fabricate(:user_reviewer)
      Fabricate(:user_worker)

      expect(User.admins).to eq([user_admin])
    end
  end

  describe ".reporters" do
    it "includes only Reporters" do
      user_reporter = Fabricate(:user_reporter)
      Fabricate(:user_admin)
      Fabricate(:user_reviewer)
      Fabricate(:user_worker)

      expect(User.reporters).to eq([user_reporter])
    end
  end

  describe ".reviewers" do
    it "includes only Reviewers" do
      user_reviewer = Fabricate(:user_reviewer)
      Fabricate(:user_admin)
      Fabricate(:user_reporter)
      Fabricate(:user_worker)

      expect(User.reviewers).to eq([user_reviewer])
    end
  end

  describe ".workers" do
    it "includes only Workers" do
      user_worker = Fabricate(:user_worker)
      Fabricate(:user_admin)
      Fabricate(:user_reporter)
      Fabricate(:user_reviewer)

      expect(User.workers).to eq([user_worker])
    end
  end

  describe ".assignable_employees" do
    it "includes Reviewers & Workers" do
      user_reviewer = Fabricate(:user_reviewer)
      user_worker = Fabricate(:user_worker)
      Fabricate(:user_admin)
      Fabricate(:user_reporter)

      expect(User.assignable_employees)
        .to contain_exactly(user_reviewer, user_worker)
    end
  end

  describe ".destroyed_name" do
    it "includes only Workers" do
      expect(User.destroyed_name).to eq("removed")
    end
  end

  describe ".unassigned" do
    let(:user) { User.unassigned }

    context "id and name" do
      it "returns 0" do
        expect(user).not_to be_nil
        expect(user.id).to eq(0)
        expect(user.name).not_to be_nil
      end
    end
  end

  # INSTANCE

  describe "#name_and_email" do
    let(:user) { Fabricate(:user) }

    context "when user has both" do
      it "returns 'name (email)'" do
        expect(user.name_and_email).to eq("#{user.name} (#{user.email})")
      end
    end

    context "when user doesn't have a name" do
      before { user.name = nil }

      it "returns their email" do
        expect(user.name_and_email).to eq(user.email)
      end
    end

    context "when user doesn't have an email" do
      before { user.email = nil }

      it "returns their name" do
        expect(user.name_and_email).to eq(user.name)
      end
    end

    context "when user doesn't have both" do
      before { user.email = user.name = nil }

      it "returns nil" do
        expect(user.name_and_email).to be_nil
      end
    end
  end

  describe "#name_or_email" do
    let(:user) { Fabricate(:user) }

    context "when user has both" do
      it "returns their.name" do
        expect(user.name_or_email).to eq(user.name)
      end
    end

    context "when user doesn't have a name" do
      before { user.name = nil }

      it "returns their email" do
        expect(user.name_or_email).to eq(user.email)
      end
    end

    context "when user doesn't have both" do
      before { user.email = user.name = nil }

      it "returns nil" do
        expect(user.name_or_email).to be_nil
      end
    end
  end

  describe "#task_assignments" do
    let(:user) { Fabricate(:user_worker) }

    before { Fabricate(:task_assignee, assignee: user) }

    context "when destroying user" do
      it "destroys it's task_assignments" do
        expect do
          user.destroy
        end.to change(TaskAssignee, :count).by(-1)
      end
    end
  end

  describe "#task_progress" do
    let(:user) { Fabricate(:user_worker) }
    let(:task) { Fabricate(:task) }

    context "when no progressions for task" do
      before { Fabricate(:finished_progression, user: user) }

      it "returns nil" do
        expect(user.task_progress(task)).to eq("")
      end
    end

    context "when a progression for the task" do
      context "that starts and stops on the same day" do
        context "a previous year" do
          before do
            Timecop.freeze("20060305 1200") do
              Fabricate(:finished_progression, task: task, user: user)
            end
          end

          it "returns one day" do
            expect(user.task_progress(task)).to eq("3/5/2006")
          end
        end

        context "current year" do
          before do
            Timecop.freeze("3/5 12:00pm") do
              Fabricate(:finished_progression, task: task, user: user)
            end
          end

          it "returns one day" do
            expect(user.task_progress(task)).to eq("3/5")
          end
        end
      end

      context "that starts and stops on different days" do
        context "a previous year" do
          before do
            progression = nil
            Timecop.freeze("20060305 1200") do
              progression = Fabricate(:progression, task: task, user: user)
            end
            Timecop.freeze("20060306 1200") do
              progression.finish
            end
          end

          it "returns both days" do
            expect(user.task_progress(task)).to eq("3/5/2006-3/6/2006")
          end
        end

        context "current year" do
          before do
            progression = nil
            Timecop.freeze("3/5 12:00pm") do
              progression = Fabricate(:progression, task: task, user: user)
            end
            Timecop.freeze("3/6 12:00pm") do
              progression.finish
            end
          end

          it "returns one day" do
            expect(user.task_progress(task)).to eq("3/5-3/6")
          end
        end
      end
    end

    context "when two progressions for the task" do
      context "and each are on different days" do
        before do
          progression = nil
          Timecop.freeze("3/8 12:00pm") do
            progression = Fabricate(:progression, task: task, user: user)
          end
          Timecop.freeze("3/10 12:00pm") do
            progression.finish
          end
          Timecop.freeze("3/5 12:00pm") do
            Fabricate(:finished_progression, task: task, user: user)
          end
        end

        it "returns one day" do
          expect(user.task_progress(task)).to eq("3/5, 3/8-3/10")
        end
      end

      context "and all are on the same day" do
        before do
          Timecop.freeze("3/5 12:00pm") do
            Fabricate(:finished_progression, task: task, user: user)
          end
          Timecop.freeze("3/5 1:00pm") do
            Fabricate(:finished_progression, task: task, user: user)
          end
        end

        it "returns one day" do
          expect(user.task_progress(task)).to eq("3/5")
        end
      end
    end
  end

  describe "#finish_progressions" do
    let(:user) { Fabricate(:user_worker) }

    context "when user has an unfinished progression" do
      let(:task) { Fabricate(:open_task) }

      before { task.assignees << user }

      it "changes it's finished to true" do
        progression = Fabricate(:unfinished_progression, task: task, user: user)

        expect do
          user.finish_progressions
          progression.reload
        end.to change(progression, :finished).to(true)
      end
    end

    context "when user has no unfinished progressions" do
      it "doesn't raise an error" do
        expect do
          user.finish_progressions
        end.not_to raise_error
      end
    end
  end
end
