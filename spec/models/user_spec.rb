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

  it { is_expected.to have_many(:issues) }
  it { is_expected.to have_many(:issue_comments) }
  it { is_expected.to have_many(:tasks) }
  it { is_expected.to have_many(:task_comments) }
  it { is_expected.to have_many(:task_assignees) }
  it { is_expected.to have_many(:assignments) }
  it { is_expected.to have_many(:progressions) }
  it { is_expected.to have_many(:reviews) }
  it { is_expected.to have_many(:issue_subscriptions).dependent(:destroy) }
  it { is_expected.to have_many(:subscribed_issues) }
  it { is_expected.to have_many(:task_subscriptions).dependent(:destroy) }
  it { is_expected.to have_many(:subscribed_tasks) }

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

  describe "#admin?" do
    context "when employee_type is" do
      context "Admin" do
        before { subject.employee_type = "Admin" }

        it "returns true" do
          expect(subject.admin?).to eq(true)
        end
      end

      %w[Reviewer Reporter Worker].each do |employee_type|
        context employee_type.to_s do
          before { subject.employee_type = employee_type }

          it "returns false" do
            expect(subject.admin?).to eq(false)
          end
        end
      end
    end
  end

  describe "#reviewer?" do
    context "when employee_type is" do
      context "Reviewer" do
        before { subject.employee_type = "Reviewer" }

        it "returns true" do
          expect(subject.reviewer?).to eq(true)
        end
      end

      %w[Admin Reporter Worker].each do |employee_type|
        context employee_type.to_s do
          before { subject.employee_type = employee_type }

          it "returns false" do
            expect(subject.reviewer?).to eq(false)
          end
        end
      end
    end
  end

  describe "#reporter?" do
    context "when employee_type is" do
      context "Reporter" do
        before { subject.employee_type = "Reporter" }

        it "returns true" do
          expect(subject.reporter?).to eq(true)
        end
      end

      %w[Admin Reviewer Worker].each do |employee_type|
        context employee_type.to_s do
          before { subject.employee_type = employee_type }

          it "returns false" do
            expect(subject.reporter?).to eq(false)
          end
        end
      end
    end
  end

  describe "#worker?" do
    context "when employee_type is" do
      context "Worker" do
        before { subject.employee_type = "Worker" }

        it "returns true" do
          expect(subject.worker?).to eq(true)
        end
      end

      %w[Admin Reviewer Reporter].each do |employee_type|
        context employee_type.to_s do
          before { subject.employee_type = employee_type }

          it "returns false" do
            expect(subject.worker?).to eq(false)
          end
        end
      end
    end
  end

  describe "#employee?" do
    let(:user) { Fabricate(:user_worker) }

    %w[Admin Reviewer Worker Reporter].each do |employee_type|
      context "when employee_type is #{employee_type}" do
        before { user.employee_type = employee_type }

        it "returns true" do
          expect(user.employee?).to eq(true)
        end
      end
    end

    context "when employee_type is something else" do
      before { user.employee_type = "something" }

      it "returns false" do
        expect(user.employee?).to eq(false)
      end
    end
  end

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

  describe "#unresolved_issues" do
    let(:user) { Fabricate(:user_worker) }

    context "when user has no issues" do
      before { Fabricate(:issue) }

      it "returns []" do
        expect(user.unresolved_issues).to eq([])
      end
    end

    context "when user has issues" do
      it "returns all unresolved" do
        open_issue = Fabricate(:open_issue, user: user)
        being_worked_on_issue = Fabricate(:open_issue, user: user)
        Fabricate(:open_task, issue: being_worked_on_issue)
        addressed_issue = Fabricate(:open_issue, user: user)
        Fabricate(:approved_task, issue: addressed_issue)
        Fabricate(:closed_issue, user: user)

        expect(user.unresolved_issues)
          .to contain_exactly(open_issue, being_worked_on_issue,
                              addressed_issue)
      end

      it "orders by issues.created_at desc" do
        second_issue = nil
        Timecop.freeze(1.day.ago) do
          second_issue = Fabricate(:open_issue, user: user)
        end
        first_issue = Fabricate(:open_issue, user: user)

        expect(user.unresolved_issues).to eq([first_issue, second_issue])
      end

      it "orders by other user comments.created_at desc" do
        second_issue = Fabricate(:open_issue, user: user)
        first_issue = nil
        Timecop.freeze(2.days.ago) do
          first_issue = Fabricate(:open_issue, user: user)
          Fabricate(:issue_comment, issue: second_issue)
        end
        Timecop.freeze(1.day.ago) do
          Fabricate(:issue_comment, issue: first_issue)
        end
        Fabricate(:issue_comment, issue: second_issue, user: user)

        expect(user.unresolved_issues).to eq([first_issue, second_issue])
      end

      it "orders by open_tasks_count, tasks_count" do
        second_issue = Fabricate(:open_issue, user: user)
        first_issue = nil
        Timecop.freeze(1.day.ago) do
          first_issue = Fabricate(:open_issue, user: user)
        end
        Fabricate(:open_task, issue: first_issue)
        2.times { Fabricate(:closed_task, issue: second_issue) }

        expect(user.unresolved_issues).to eq([first_issue, second_issue])
      end
    end
  end

  describe "#active_assignments" do
    let(:user) { Fabricate(:user_worker) }
    let(:closed_task) { Fabricate(:closed_task) }
    let(:open_task) { Fabricate(:open_task) }

    context "when user has no assignments" do
      it "returns []" do
        expect(user.active_assignments).to eq([])
      end
    end

    context "when user has an assignment" do
      before do
        closed_task.assignees << user
        open_task.assignees << user
      end

      it "returns open tasks" do
        expect(user.active_assignments).to eq([open_task])
      end
    end

    context "when user has multiple assignments" do
      let(:in_progress_task) { Fabricate(:open_task, summary: "In Progress") }
      let(:paused_task) { Fabricate(:open_task, summary: "Paused") }
      let(:assigned_task) { Fabricate(:open_task, summary: "Assigned") }
      let(:in_review_task) { Fabricate(:open_task, summary: "In Review") }

      before do
        [paused_task, in_review_task, in_progress_task,
         assigned_task].each do |task|
          task.assignees << user
        end
        Fabricate(:finished_progression, task: paused_task, user: user)
        Fabricate(:unfinished_progression, task: in_progress_task, user: user)
        Fabricate(:pending_review, task: in_review_task, user: user)
      end

      it "orders tasks by in progress, with progressions, assigned" do
        tasks = [in_progress_task, paused_task, assigned_task,
                 in_review_task]
        expect(user.active_assignments).to match_array(tasks)
        expect(user.active_assignments).to eq(tasks)
      end
    end

    context "when user has 2 tasks with no progressions" do
      before do
      end

      it "orders by tasks.created_at desc" do
        second_task = nil
        Timecop.freeze(1.week.ago) do
          second_task = Fabricate(:open_task)
        end
        first_task = Fabricate(:open_task)
        [second_task, first_task].each do |task|
          task.assignees << user
        end

        expect(user.active_assignments).to eq([first_task, second_task])
      end
    end

    context "when user has 2 tasks with a progression" do
      before do
      end

      it "orders by progressions.created_at desc" do
        first_task = nil
        second_task = nil
        Timecop.freeze(1.week.ago) do
          second_task = Fabricate(:open_task)
          first_task = Fabricate(:open_task)
        end

        [second_task, first_task].each do |task|
          task.assignees << user
        end

        Timecop.freeze(1.day.ago) do
          Fabricate(:finished_progression, task: second_task, user: user)
        end
        Fabricate(:finished_progression, task: first_task, user: user)

        expect(user.active_assignments).to eq([first_task, second_task])
      end
    end

    context "when user has 2 tasks with a comment" do
      before do
      end

      it "orders by task_comments.created_at desc" do
        first_task = nil
        second_task = nil
        Timecop.freeze(1.week.ago) do
          second_task = Fabricate(:open_task)
          first_task = Fabricate(:open_task)
        end

        [second_task, first_task].each do |task|
          task.assignees << user
        end

        Timecop.freeze(2.days.ago) do
          Fabricate(:task_comment, task: second_task)
        end
        Timecop.freeze(1.day.ago) do
          Fabricate(:task_comment, task: first_task)
        end
        Fabricate(:task_comment, task: second_task, user: user)

        expect(user.active_assignments).to eq([first_task, second_task])
      end
    end
  end

  describe "#open_tasks" do
    let(:user) { Fabricate(:user_reviewer) }

    context "when user has no tasks" do
      it "returns []" do
        expect(user.open_tasks).to eq([])
      end
    end

    context "when user an open and closed task" do
      before do
        Fabricate(:closed_task, user: user)
        Fabricate(:open_task)
      end

      it "returns non-closed only" do
        task = Fabricate(:open_task, user: user)

        expect(user.open_tasks).to eq([task])
      end
    end

    context "when user has different status tasks" do
      let(:in_progress_task) do
        Fabricate(:open_task, user: user, summary: "In Progress")
      end
      let(:assigned_task) do
        Fabricate(:open_task, user: user, summary: "Assigned")
      end
      let(:in_review_task) do
        Fabricate(:open_task, user: user, summary: "In Review")
      end

      before do
        Fabricate(:unfinished_progression, task: in_progress_task)
        Fabricate(:pending_review, task: in_review_task)
      end

      it "orders by in_review, in_progress, assigned, open" do
        open_task = Fabricate(:open_task, user: user, summary: "Open")
        tasks = [in_review_task, in_progress_task, assigned_task, open_task]
        expect(user.open_tasks).to eq(tasks)
      end
    end

    context "when user has similar status tasks" do
      it "orders by last comment by another user" do
        first_task = nil
        second_task = nil

        Timecop.freeze(1.week.ago) do
          first_task = Fabricate(:open_task, user: user)
        end
        Timecop.freeze(1.day.ago) do
          second_task = Fabricate(:open_task, user: user)
          Fabricate(:task_comment, task: second_task)
        end
        Fabricate(:task_comment, task: first_task)
        Fabricate(:task_comment, task: second_task, user: user)

        tasks = [first_task, second_task]
        expect(user.open_tasks).to eq(tasks)
      end

      it "orders by last progression" do
        first_task = nil
        second_task = nil

        Timecop.freeze(1.week.ago) do
          first_task = Fabricate(:open_task, user: user)
        end
        Timecop.freeze(1.day.ago) do
          second_task = Fabricate(:open_task, user: user)
          Fabricate(:progression, task: second_task)
        end
        Fabricate(:progression, task: first_task)

        tasks = [first_task, second_task]
        expect(user.open_tasks).to eq(tasks)
      end
    end
  end
end
