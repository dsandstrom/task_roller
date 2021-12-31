# frozen_string_literal: true

require "rails_helper"

EnvStruct = Struct.new(:info, :uid)
InfoStruct = Struct.new(:email, :name, :nickname)

RSpec.describe User, type: :model do
  let(:example_user) { Fabricate.build(:user) }

  before do
    @user = User.new(name: "User Name", email: "test@example.com",
                     employee_type: "Worker", password: "password",
                     password_confirmation: "password",
                     confirmed_at: Time.zone.now)
  end

  subject { @user }

  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:email) }
  it { is_expected.to respond_to(:employee_type) }
  it { is_expected.to respond_to(:github_id) }
  it { is_expected.to respond_to(:github_username) }

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
  it do
    is_expected.to have_many(:category_issues_subscriptions).dependent(:destroy)
  end
  it do
    is_expected.to have_many(:category_tasks_subscriptions).dependent(:destroy)
  end
  it do
    is_expected.to have_many(:project_issues_subscriptions).dependent(:destroy)
  end
  it do
    is_expected.to have_many(:project_tasks_subscriptions).dependent(:destroy)
  end
  it { is_expected.to have_many(:subscribed_issue_categories) }
  it { is_expected.to have_many(:subscribed_task_categories) }
  it { is_expected.to have_many(:issue_closures) }
  it { is_expected.to have_many(:task_closures) }
  it { is_expected.to have_many(:issue_reopenings) }
  it { is_expected.to have_many(:task_reopenings) }
  it { is_expected.to have_many(:issue_notifications).dependent(:destroy) }
  it { is_expected.to have_many(:task_notifications).dependent(:destroy) }
  it { is_expected.to have_many(:notifying_tasks) }
  it { is_expected.to have_many(:notifying_issues) }
  it { is_expected.to have_many(:repo_callouts) }

  it { is_expected.to be_valid }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  it { is_expected.to validate_uniqueness_of(:github_id) }

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

  describe "#allow_registration?" do
    after { ENV["USER_REGISTRATION"] = nil }

    context "when ENV['USER_REGISTRATION'] is not set" do
      before { ENV["USER_REGISTRATION"] = nil }

      it "returns false" do
        expect(User.allow_registration?).to eq(false)
      end
    end

    context "when ENV['USER_REGISTRATION'] is enabled" do
      before { ENV["USER_REGISTRATION"] = "enabled" }

      it "returns true" do
        expect(User.allow_registration?).to eq(true)
      end
    end

    context "when ENV['USER_REGISTRATION'] is disabled" do
      before { ENV["USER_REGISTRATION"] = "disabled" }

      it "returns false" do
        expect(User.allow_registration?).to eq(false)
      end
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

  describe ".unemployed" do
    it "includes only Workers" do
      nil_user = Fabricate(:user)
      nil_user.update_attribute :employee_type, nil
      blank_user = Fabricate(:user)
      blank_user.update_attribute :employee_type, ""
      invalid_user = Fabricate(:user)
      invalid_user.update_attribute :employee_type, "invalid"
      Fabricate(:user_admin)
      Fabricate(:user_reporter)
      Fabricate(:user_reviewer)
      Fabricate(:user_worker)

      expect(User.unemployed)
        .to contain_exactly(nil_user, blank_user, invalid_user)
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

  describe ".assigned_to" do
    context "for an open task" do
      let(:task) { Fabricate(:open_task) }

      context "and no assignees and progressions" do
        it "returns none" do
          expect(User.assigned_to(task)).to eq([])
        end
      end

      context "and an assignee" do
        let(:user) { Fabricate(:user_worker) }

        before { Fabricate(:task_assignee, task: task, assignee: user) }

        it "returns none" do
          expect(User.assigned_to(task)).to eq([])
        end
      end

      context "and a progression" do
        let(:user) { Fabricate(:user_worker) }

        before { Fabricate(:progression, task: task, user: user) }

        it "returns progression users" do
          expect(User.assigned_to(task)).to eq([user])
        end
      end

      context "and a progression user is also an assignee" do
        let(:user) { Fabricate(:user_worker) }

        before do
          task.assignees << user
          Fabricate(:progression, task: task, user: user)
        end

        it "returns none" do
          expect(User.assigned_to(task)).to eq([])
        end
      end

      context "and two progressions" do
        context "for the same user" do
          let(:user) { Fabricate(:user_worker) }

          before do
            Fabricate(:finished_progression, task: task, user: user)
            Fabricate(:progression, task: task, user: user)
          end

          it "returns user once" do
            expect(User.assigned_to(task)).to eq([user])
          end
        end

        context "for the different users" do
          let(:first_user) { Fabricate(:user_worker) }
          let(:second_user) { Fabricate(:user_worker) }

          before do
            Fabricate(:finished_progression, task: task, user: second_user)

            Timecop.freeze(1.day.ago) do
              Fabricate(:finished_progression, task: task, user: first_user)
            end
          end

          it "orders by created_at" do
            expect(User.assigned_to(task)).to eq([first_user, second_user])
          end
        end
      end
    end

    context "for an closed task" do
      let(:task) { Fabricate(:closed_task) }

      context "and no assignees and progressions" do
        it "returns none" do
          expect(User.assigned_to(task)).to eq([])
        end
      end

      context "and an assignee" do
        let(:user) { Fabricate(:user_worker) }

        before { Fabricate(:task_assignee, task: task, assignee: user) }

        it "returns assignee" do
          expect(User.assigned_to(task)).to eq([user])
        end
      end

      context "and a progression" do
        let(:user) { Fabricate(:user_worker) }

        before { Fabricate(:progression, task: task, user: user) }

        it "returns progression users" do
          expect(User.assigned_to(task)).to eq([user])
        end
      end

      context "and a progression user is also an assignee" do
        let(:user) { Fabricate(:user_worker) }

        before do
          task.assignees << user
          Fabricate(:progression, task: task, user: user)
        end

        it "returns user" do
          expect(User.assigned_to(task)).to eq([user])
        end
      end

      context "and a progression user and a different assignee" do
        let(:user) { Fabricate(:user_worker) }
        let(:assignee) { Fabricate(:user_worker) }

        before do
          task.assignees << user
          task.assignees << assignee
          Fabricate(:progression, task: task, user: user)
        end

        it "returns both" do
          expect(User.assigned_to(task)).to contain_exactly(user, assignee)
        end
      end

      context "and two progressions" do
        context "for the same user" do
          let(:user) { Fabricate(:user_worker) }

          before do
            Fabricate(:finished_progression, task: task, user: user)
            Fabricate(:progression, task: task, user: user)
          end

          it "returns user once" do
            expect(User.assigned_to(task)).to eq([user])
          end
        end

        context "for the different users" do
          let(:first_user) { Fabricate(:user_worker) }
          let(:second_user) { Fabricate(:user_worker) }

          before do
            Fabricate(:finished_progression, task: task, user: second_user)

            Timecop.freeze(1.day.ago) do
              Fabricate(:finished_progression, task: task, user: first_user)
            end
          end

          it "orders by created_at" do
            expect(User.assigned_to(task)).to eq([first_user, second_user])
          end
        end
      end

      context "and two assignees" do
        let(:first_user) { Fabricate(:user_worker) }
        let(:second_user) { Fabricate(:user_worker) }

        before do
          Fabricate(:task_assignee, task: task, assignee: second_user)

          Timecop.freeze(1.day.ago) do
            Fabricate(:task_assignee, task: task, assignee: first_user)
          end
        end

        it "orders by created_at" do
          expect(User.assigned_to(task)).to eq([first_user, second_user])
        end
      end
    end
  end

  describe ".from_omniauth" do
    context "when no users" do
      context "when invalid environment" do
        let(:env) { EnvStruct.new(InfoStruct.new, nil) }

        it "doesn't create a new user" do
          expect do
            User.from_omniauth(env)
          end.not_to change(User, :count)
        end

        it "returns nil" do
          user = User.from_omniauth(env)
          expect(user).to be_nil
        end
      end

      context "when invalid user data" do
        let(:env) { EnvStruct.new(nil, 1234) }

        it "doesn't create a new user" do
          expect do
            User.from_omniauth(env)
          end.not_to change(User, :count)
        end

        it "returns nil" do
          user = User.from_omniauth(env)
          expect(user).to be_nil
        end
      end

      context "when valid omniauth env" do
        let(:env) do
          EnvStruct.new(
            InfoStruct.new(example_user.email, example_user.name, "username"),
            1234
          )
        end

        it "creates a new user" do
          expect do
            User.from_omniauth(env)
          end.to change(User, :count).by(1)
        end

        it "sets user attributes" do
          user = User.from_omniauth(env)
          expect(user.persisted?).to eq(true)
          expect(user.name).to eq(example_user.name)
          expect(user.email).to eq(example_user.email)
          expect(user.employee_type).to eq("Reporter")
          expect(user.confirmed?).to eq(true)
          expect(user.github_id).to eq(1234)
          expect(user.github_username).to eq("username")
        end
      end
    end

    context "when users" do
      context "when invalid user" do
        let!(:existing_user) { Fabricate(:user_reviewer, github_id: 1234) }

        let(:env) { EnvStruct.new(InfoStruct.new) }

        it "doesn't create a new user" do
          expect do
            User.from_omniauth(env)
          end.not_to change(User, :count)
        end

        it "returns nil" do
          user = User.from_omniauth(env)
          expect(user).to be_nil
        end
      end

      context "when valid omniauth env" do
        context "when a matching user exists" do
          let!(:existing_user) { Fabricate(:user_reviewer, github_id: 1234) }
          let(:env) do
            EnvStruct.new(
              InfoStruct.new(existing_user.email, existing_user.name,
                             "username"),
              1234
            )
          end

          it "doesn't create a new user" do
            expect do
              User.from_omniauth(env)
            end.not_to change(User, :count)
          end

          it "returns a new user" do
            user = User.from_omniauth(env)
            expect(user.persisted?).to eq(true)
            expect(user.name).to eq(existing_user.name)
            expect(user.email).to eq(existing_user.email)
            expect(user.employee_type).to eq(existing_user.employee_type)
            expect(user.confirmed?).to eq(true)
            expect(user.github_id).to eq(1234)
          end
        end

        context "when new user data" do
          let(:env) do
            EnvStruct.new(
              InfoStruct.new(example_user.email, example_user.name, "username"),
              1234
            )
          end

          it "creates a new user" do
            expect do
              User.from_omniauth(env)
            end.to change(User, :count).by(1)
          end

          it "returns a new user" do
            user = User.from_omniauth(env)
            expect(user.persisted?).to eq(true)
            expect(user.name).to eq(example_user.name)
            expect(user.email).to eq(example_user.email)
            expect(user.employee_type).to eq("Reporter")
            expect(user.confirmed?).to eq(true)
            expect(user.github_id).to eq(1234)
            expect(user.github_username).to eq("username")
          end
        end
      end
    end
  end

  describe ".new_with_session" do
    let(:example_user) { Fabricate.build(:user) }
    let(:params) { {} }
    let(:session) do
      {
        "devise.github_data" => {
          "email" => example_user.email,
          "extra" => { "raw_info" => {} }
        }
      }
    end

    context "when no users" do
      it "retuns nil" do
        expect(User.new_with_session(params, session)).to be_a_new(User)
      end
    end

    context "when a user doesn't match" do
      before { Fabricate(:user_reviewer) }

      it "retuns a new user" do
        user = User.new_with_session(params, session)
        expect(user).to be_a_new(User)
        expect(user.email).to eq(example_user.email)
      end
    end

    context "when a user matches" do
      before do
        Fabricate(:user_reviewer)
        example_user.save
      end

      it "retuns a new user" do
        user = User.new_with_session(params, session)
        expect(user).to be_a_new(User)
        expect(user.email).to eq(example_user.email)
      end
    end
  end

  # INSTANCE

  describe "#add_omniauth" do
    let(:user) { Fabricate(:user_reviewer) }

    context "when invalid environment" do
      let(:env) { EnvStruct.new({}, nil) }

      it "doesn't update user" do
        expect do
          user.add_omniauth(env)
          user.reload
        end.not_to change(user, :github_id)
      end

      it "returns false" do
        expect(user.add_omniauth(env)).to eq(false)
      end
    end

    context "when invalid user data" do
      let(:env) { EnvStruct.new(nil, 1234) }

      it "doesn't create a new user" do
        expect do
          user.add_omniauth(env)
          user.reload
        end.not_to change(user, :github_id)
      end

      it "returns false" do
        expect(user.add_omniauth(env)).to eq(false)
      end
    end

    context "when valid omniauth env" do
      let(:env) do
        EnvStruct.new(
          InfoStruct.new(example_user.email, example_user.name, "username"),
          1234
        )
      end

      it "updates github_id" do
        expect do
          user.add_omniauth(env)
          user.reload
        end.to change(user, :github_id).to(1234)
      end

      it "updates github_username" do
        expect do
          user.add_omniauth(env)
          user.reload
        end.to change(user, :github_username).to("username")
      end

      it "doesn't change employee_type" do
        expect do
          user.add_omniauth(env)
          user.reload
        end.not_to change(user, :employee_type)
      end
    end

    context "when github_id already taken" do
      let(:env) do
        EnvStruct.new(
          InfoStruct.new(example_user.email, example_user.name, "username"),
          1234
        )
      end

      before { Fabricate(:user_reporter, github_id: 1234) }

      it "doesn't change github_id" do
        expect do
          user.add_omniauth(env)
          user.reload
        end.not_to change(user, :github_id)
      end

      it "doesn't change github_username" do
        expect do
          user.add_omniauth(env)
          user.reload
        end.not_to change(user, :github_username)
      end
    end

    context "when unconfirmed" do
      let(:env) do
        EnvStruct.new(
          InfoStruct.new(example_user.email, example_user.name, "username"),
          1234
        )
      end

      before { user.update_attribute :confirmed_at, nil }

      it "doesn't change github_id" do
        expect do
          user.add_omniauth(env)
          user.reload
        end.not_to change(user, :github_id)
      end
    end
  end

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
        being_worked_on_issue.update_status
        addressed_issue = Fabricate(:open_issue, user: user)
        Fabricate(:approved_task, issue: addressed_issue)
        addressed_issue.update_status
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

        issues = [first_issue, second_issue]
        issues.each(&:update_status)
        expect(user.unresolved_issues).to eq(issues)
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

        issues = [first_issue, second_issue]
        issues.each(&:update_status)
        expect(user.unresolved_issues).to eq(issues)
      end

      it "orders by open_tasks_count, tasks_count" do
        second_issue = Fabricate(:open_issue, user: user)
        first_issue = nil
        Timecop.freeze(1.day.ago) do
          first_issue = Fabricate(:open_issue, user: user)
        end
        Fabricate(:open_task, issue: first_issue)
        2.times { Fabricate(:closed_task, issue: second_issue) }

        issues = [first_issue, second_issue]
        issues.each(&:update_status)
        expect(user.unresolved_issues).to eq(issues)
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
        open_task.update_status
      end

      it "returns open tasks" do
        expect(user.active_assignments).to eq([open_task])
      end
    end

    context "when user has a shared assignment" do
      let(:another_user) { Fabricate(:user_worker) }

      before do
        Fabricate(:task_assignee, task: open_task, assignee: user)
        Fabricate(:task_assignee, task: open_task, assignee: another_user)
        Fabricate(:progression, task: open_task, user: another_user)
        open_task.update_status
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
        tasks.each(&:update_status)
        expect(user.active_assignments).to match_array(tasks)
        expect(user.active_assignments).to eq(tasks)
      end
    end

    context "when user has 2 tasks with no progressions" do
      it "orders by tasks.created_at desc" do
        second_task = nil
        Timecop.freeze(1.week.ago) do
          second_task = Fabricate(:open_task)
        end
        first_task = Fabricate(:open_task)
        [second_task, first_task].each do |task|
          task.assignees << user
        end

        tasks = [first_task, second_task]
        tasks.each(&:update_status)
        expect(user.active_assignments).to eq(tasks)
      end
    end

    context "when user has 2 tasks with a progression" do
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

        tasks = [first_task, second_task]
        tasks.each(&:update_status)
        expect(user.active_assignments).to eq(tasks)
      end
    end

    context "when user has 2 tasks with a comment" do
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

        tasks = [first_task, second_task]
        tasks.each(&:update_status)
        expect(user.active_assignments).to eq(tasks)
      end
    end

    context "when user commented on assigned task" do
      it "still includes it" do
        task = Fabricate(:open_task, user: user)
        task.assignees << user
        Fabricate(:task_comment, task: task, user: user)

        expect(user.active_assignments).to eq([task])
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
        tasks.each(&:update_status)
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
        tasks.each(&:update_status)
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
        tasks.each(&:update_status)
        expect(user.open_tasks).to eq(tasks)
      end
    end
  end

  # https://github.com/heartcombo/devise/wiki/How-To:-Email-only-sign-up
  # catch any changes in Devise's behavior in the future
  describe "#set_reset_password_token" do
    it "returns the plaintext token" do
      potential_token = subject.send(:set_reset_password_token)
      potential_token_digest =
        Devise.token_generator.digest(subject, :reset_password_token,
                                      potential_token)
      actual_token_digest = subject.reset_password_token
      expect(potential_token_digest).to eql(actual_token_digest)
    end
  end

  describe "#active_for_authentication?" do
    context "for an admin" do
      let(:user) { Fabricate(:user_admin) }

      it "returns true" do
        expect(user.active_for_authentication?).to eq(true)
      end
    end

    context "for a reviewer" do
      let(:user) { Fabricate(:user_reviewer) }

      it "returns true" do
        expect(user.active_for_authentication?).to eq(true)
      end
    end

    context "for a worker" do
      let(:user) { Fabricate(:user_worker) }

      it "returns true" do
        expect(user.active_for_authentication?).to eq(true)
      end
    end

    context "for a reporter" do
      let(:user) { Fabricate(:user_reporter) }

      it "returns true" do
        expect(user.active_for_authentication?).to eq(true)
      end
    end

    context "for an unconfirmed reporter" do
      let(:user) do
        Fabricate(:user_reporter, confirmed_at: nil)
      end

      it "returns false" do
        expect(user.active_for_authentication?).to eq(false)
      end
    end

    context "for a non-employee" do
      let(:user) { Fabricate(:user_unemployed) }

      it "returns false" do
        expect(user.active_for_authentication?).to eq(false)
      end
    end
  end

  describe "#password?" do
    context "when user has an encrypted_password" do
      let(:user) { Fabricate(:user) }

      it "returns true" do
        expect(user.password?).to eq(true)
      end
    end

    context "when user doesn't have an encrypted_password" do
      let(:user) do
        Fabricate(:user, password: nil, password_confirmation: nil,
                         confirmed_at: nil)
      end

      it "returns false" do
        expect(user.password?).to eq(false)
      end
    end
  end

  describe "#subscriptions" do
    let(:user) { Fabricate(:user_worker) }
    let(:task) { Fabricate(:task) }
    let(:issue) { Fabricate(:issue) }

    context "when no task_subscriptions" do
      before { Fabricate(:task_subscription, task: task) }

      it "returns []" do
        expect(user.subscriptions).to eq([])
      end
    end

    context "when a task_subscription" do
      before { Fabricate(:task_subscription, task: task, user: user) }

      it "returns task" do
        expect(user.subscriptions.map(&:id)).to eq([task.id])
      end
    end

    context "when a issue_subscription" do
      before { Fabricate(:issue_subscription, issue: issue, user: user) }

      it "returns issue" do
        expect(user.subscriptions.map(&:id)).to eq([issue.id])
      end
    end
  end

  describe "#subscribed_issues_with_notifications" do
    let(:user) { Fabricate(:user_worker) }
    let(:first_issue) { Fabricate(:issue) }
    let(:second_issue) { Fabricate(:issue) }

    context "when no subscriptions" do
      before { Fabricate(:issue_subscription, issue: first_issue) }

      it "returns none" do
        expect(user.subscribed_issues_with_notifications).to eq([])
      end
    end

    context "when issue_subscription" do
      before { Fabricate(:issue_subscription, issue: first_issue, user: user) }

      it "returns it's issue" do
        expect(user.subscribed_issues_with_notifications).to eq([first_issue])
      end
    end

    context "when 2 issue_subscriptions" do
      context "and order_by is not set" do
        before do
          Timecop.freeze(1.week.ago) do
            Fabricate(:issue_subscription, issue: first_issue, user: user)
          end
          Timecop.freeze(1.day.ago) do
            Fabricate(:issue_subscription, issue: second_issue, user: user)
          end
          Fabricate(:issue_notification, issue: first_issue, user: user)
          Fabricate(:issue_notification, issue: second_issue)
        end

        it "returns it's issue" do
          expect(
            user.subscribed_issues_with_notifications
                .order("updated_at desc")
          ).to eq([second_issue, first_issue])
        end
      end

      context "and order_by is false" do
        before do
          Timecop.freeze(1.week.ago) do
            Fabricate(:issue_subscription, issue: first_issue, user: user)
          end
          Timecop.freeze(1.day.ago) do
            Fabricate(:issue_subscription, issue: second_issue, user: user)
          end
          Fabricate(:issue_notification, issue: first_issue, user: user)
          Fabricate(:issue_notification, issue: second_issue)
        end

        it "returns it's issue" do
          expect(
            user.subscribed_issues_with_notifications(order_by: false)
                .order("updated_at desc")
          ).to eq([second_issue, first_issue])
        end
      end

      context "and order_by is true" do
        before do
          Timecop.freeze(1.week.ago) do
            Fabricate(:issue_subscription, issue: first_issue, user: user)
          end
          Timecop.freeze(1.day.ago) do
            Fabricate(:issue_subscription, issue: second_issue, user: user)
          end
          Fabricate(:issue_notification, issue: first_issue, user: user)
          Fabricate(:issue_notification, issue: second_issue)
        end

        it "returns it's issue" do
          expect(
            user.subscribed_issues_with_notifications(order_by: true)
                .order("updated_at desc")
          ).to eq([first_issue, second_issue])
        end
      end
    end
  end

  describe "#subscribed_tasks_with_notifications" do
    let(:user) { Fabricate(:user_worker) }
    let(:first_task) { Fabricate(:task) }
    let(:second_task) { Fabricate(:task) }

    context "when no subscriptions" do
      before { Fabricate(:task_subscription, task: first_task) }

      it "returns none" do
        expect(user.subscribed_tasks_with_notifications).to eq([])
      end
    end

    context "when task_subscription" do
      before { Fabricate(:task_subscription, task: first_task, user: user) }

      it "returns it's task" do
        expect(user.subscribed_tasks_with_notifications).to eq([first_task])
      end
    end

    context "when 2 task_subscriptions" do
      context "and order_by is not set" do
        before do
          Timecop.freeze(1.week.ago) do
            Fabricate(:task_subscription, task: first_task, user: user)
          end
          Timecop.freeze(1.day.ago) do
            Fabricate(:task_subscription, task: second_task, user: user)
          end
          Fabricate(:task_notification, task: first_task, user: user)
          Fabricate(:task_notification, task: second_task)
        end

        it "returns it's task" do
          expect(
            user.subscribed_tasks_with_notifications
                .order("updated_at desc")
          ).to eq([second_task, first_task])
        end
      end

      context "and order_by is false" do
        before do
          Timecop.freeze(1.week.ago) do
            Fabricate(:task_subscription, task: first_task, user: user)
          end
          Timecop.freeze(1.day.ago) do
            Fabricate(:task_subscription, task: second_task, user: user)
          end
          Fabricate(:task_notification, task: first_task, user: user)
          Fabricate(:task_notification, task: second_task)
        end

        it "returns it's task" do
          expect(
            user.subscribed_tasks_with_notifications(order_by: false)
                .order("updated_at desc")
          ).to eq([second_task, first_task])
        end
      end

      context "and order_by is true" do
        before do
          Timecop.freeze(1.week.ago) do
            Fabricate(:task_subscription, task: first_task, user: user)
          end
          Timecop.freeze(1.day.ago) do
            Fabricate(:task_subscription, task: second_task, user: user)
          end
          Fabricate(:task_notification, task: first_task, user: user)
          Fabricate(:task_notification, task: second_task)
        end

        it "returns it's task" do
          expect(
            user.subscribed_tasks_with_notifications(order_by: true)
                .order("updated_at desc")
          ).to eq([first_task, second_task])
        end
      end
    end
  end

  describe "#subscriptions_with_notifications" do
    let(:user) { Fabricate(:user_worker) }
    let(:first_issue) { Fabricate(:issue) }
    let(:second_issue) { Fabricate(:issue) }
    let(:first_task) { Fabricate(:task) }
    let(:second_task) { Fabricate(:task) }

    context "when no subscriptions" do
      before { Fabricate(:task_subscription, task: first_task) }

      it "returns none" do
        expect(user.subscriptions_with_notifications).to eq([])
      end
    end

    context "when issue_subscription" do
      before { Fabricate(:issue_subscription, issue: first_issue, user: user) }

      it "returns it's issue" do
        expect(user.subscriptions_with_notifications.map(&:id))
          .to eq([first_issue.id])
      end
    end

    context "when task_subscription" do
      before { Fabricate(:task_subscription, task: first_task, user: user) }

      it "returns it's task" do
        expect(user.subscriptions_with_notifications.map(&:id))
          .to eq([first_task.id])
      end
    end

    context "when 2 issue_subscriptions" do
      context "and order_by is not set" do
        before do
          Timecop.freeze(1.week.ago) do
            Fabricate(:issue_subscription, issue: first_issue, user: user)
          end
          Timecop.freeze(1.day.ago) do
            Fabricate(:issue_subscription, issue: second_issue, user: user)
          end
          Fabricate(:issue_notification, issue: first_issue, user: user)
          Fabricate(:issue_notification, issue: second_issue)
        end

        it "returns it's issue" do
          expect(
            user.subscriptions_with_notifications
                .order("updated_at desc").map(&:id)
          ).to eq([second_issue.id, first_issue.id])
        end
      end

      context "and order_by is false" do
        before do
          Timecop.freeze(1.week.ago) do
            Fabricate(:issue_subscription, issue: first_issue, user: user)
          end
          Timecop.freeze(1.day.ago) do
            Fabricate(:issue_subscription, issue: second_issue, user: user)
          end
          Fabricate(:issue_notification, issue: first_issue, user: user)
          Fabricate(:issue_notification, issue: second_issue)
        end

        it "returns it's issue" do
          expect(
            user.subscriptions_with_notifications(order_by: false)
                .order("updated_at desc").map(&:id)
          ).to eq([second_issue.id, first_issue.id])
        end
      end

      context "and order_by is true" do
        before do
          Timecop.freeze(1.week.ago) do
            Fabricate(:issue_subscription, issue: first_issue, user: user)
          end
          Timecop.freeze(1.day.ago) do
            Fabricate(:issue_subscription, issue: second_issue, user: user)
          end
          Fabricate(:issue_notification, issue: first_issue, user: user)
          Fabricate(:issue_notification, issue: second_issue)
        end

        it "returns it's issue" do
          expect(
            user.subscriptions_with_notifications(order_by: true)
                .order("updated_at desc").map(&:id)
          ).to eq([first_issue.id, second_issue.id])
        end
      end
    end

    context "when 2 task_subscriptions" do
      context "and order_by is not set" do
        before do
          Timecop.freeze(1.week.ago) do
            Fabricate(:task_subscription, task: first_task, user: user)
          end
          Timecop.freeze(1.day.ago) do
            Fabricate(:task_subscription, task: second_task, user: user)
          end
          Fabricate(:task_notification, task: first_task, user: user)
          Fabricate(:task_notification, task: second_task)
        end

        it "returns it's task" do
          expect(
            user.subscriptions_with_notifications
                .order("updated_at desc").map(&:id)
          ).to eq([second_task.id, first_task.id])
        end
      end

      context "and order_by is false" do
        before do
          Timecop.freeze(1.week.ago) do
            Fabricate(:task_subscription, task: first_task, user: user)
          end
          Timecop.freeze(1.day.ago) do
            Fabricate(:task_subscription, task: second_task, user: user)
          end
          Fabricate(:task_notification, task: first_task, user: user)
          Fabricate(:task_notification, task: second_task)
        end

        it "returns it's task" do
          expect(
            user.subscriptions_with_notifications(order_by: false)
                .order("updated_at desc").map(&:id)
          ).to eq([second_task.id, first_task.id])
        end
      end

      context "and order_by is true" do
        before do
          Timecop.freeze(1.week.ago) do
            Fabricate(:task_subscription, task: first_task, user: user)
          end
          Timecop.freeze(1.day.ago) do
            Fabricate(:task_subscription, task: second_task, user: user)
          end
          Fabricate(:task_notification, task: first_task, user: user)
          Fabricate(:task_notification, task: second_task)
        end

        it "returns it's task" do
          expect(
            user.subscriptions_with_notifications(order_by: true)
                .order("updated_at desc").map(&:id)
          ).to eq([first_task.id, second_task.id])
        end
      end
    end

    context "when issue_subscription and task_subscriptions" do
      context "and order_by is true" do
        before do
          Timecop.freeze(1.week.ago) do
            Fabricate(:issue_subscription, issue: first_issue, user: user)
          end
          Timecop.freeze(1.day.ago) do
            Fabricate(:task_subscription, task: first_task, user: user)
          end
          Fabricate(:issue_notification, issue: first_issue, user: user)
          Fabricate(:task_notification, task: first_task)
        end

        it "returns it's issue and task" do
          expect(
            user.subscriptions_with_notifications(order_by: true)
                .order("updated_at desc").map(&:id)
          ).to eq([first_issue.id, first_task.id])
        end
      end
    end
  end

  describe "#github_account" do
    context "for a user with github_id/github_username" do
      let(:user) do
        Fabricate(:user_reporter, github_id: 9432, github_username: "username")
      end

      it "has right user_id" do
        expect(user.github_account.user_id).to eq(user.id)
      end
    end

    context "for a user without github_id" do
      let(:user) do
        Fabricate(:user_reporter, github_id: nil)
      end

      it "has right user_id" do
        expect(user.github_account.user_id).to eq(user.id)
      end
    end
  end
end
