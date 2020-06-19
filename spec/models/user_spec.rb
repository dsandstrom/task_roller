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
  it { is_expected.to respond_to(:employee_id) }
  it { is_expected.to respond_to(:employee_type) }

  it { is_expected.to belong_to(:employee) }
  it { is_expected.to have_many(:task_assignees) }
  it { is_expected.to have_many(:assignments) }

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
      before { subject.employee_type = "Something Else" }

      it { is_expected.not_to be_valid }
    end
  end

  describe "on update" do
    let(:user) { Fabricate(:user) }

    before { user.employee_type = nil }

    it { expect(user).to be_valid }
  end

  # CLASS

  describe ".employees" do
    let(:user) { Fabricate(:user) }

    before { user.employee.destroy }

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

  # INSTANCE

  describe "#employee" do
    describe "destroying user" do
      it "destroys employee" do
        employee = Fabricate(:reviewer)
        user = Fabricate(:user, employee: employee)

        expect do
          user.destroy
        end.to change(Employee, :count).by(-1)
      end
    end
  end

  describe "#employee_type" do
    describe "reader" do
      context "when no employee" do
        let(:user) { Fabricate(:user) }

        before do
          user.employee_type = nil
          user.employee.destroy
        end

        it "returns nil" do
          expect(user.employee_type).to be_nil
        end
      end

      context "when employee type is 'Admin'" do
        let(:user) { Fabricate(:user_admin) }

        before { user.employee_type = nil }

        it "returns it" do
          expect(user.employee_type).to eq("Admin")
        end
      end

      context "when employee type is 'Reporter'" do
        let(:user) { Fabricate(:user_reporter) }

        before { user.employee_type = nil }

        it "returns it" do
          expect(user.employee_type).to eq("Reporter")
        end
      end

      context "when employee type is 'Reviewer'" do
        let(:user) { Fabricate(:user_reviewer) }

        before { user.employee_type = nil }

        it "returns it" do
          expect(user.employee_type).to eq("Reviewer")
        end
      end

      context "when employee type is 'Worker'" do
        let(:user) { Fabricate(:user_worker) }

        before { user.employee_type = nil }

        it "returns it" do
          expect(user.employee_type).to eq("Worker")
        end
      end
    end
  end

  describe "#create_employee" do
    context "for a new User" do
      context "for an invalid user" do
        it "doesn't create an employee" do
          user = User.new(email: "")

          expect do
            user.save
          end.not_to change(Employee, :count)
        end
      end

      context "for a valid user" do
        context "with employee_type of 'Admin'" do
          before { subject.employee_type = "Admin" }

          it "creates a Admin" do
            expect do
              subject.save
            end.to change(Admin, :count).by(1)
          end

          it "sets employee_id" do
            expect(subject.employee_id).to be_nil
            subject.save
            subject.reload
            expect(subject.employee_id).not_to be_nil
            expect(subject.employee_id).to eq(Employee.last.id)
          end
        end

        context "with employee_type of 'Reporter'" do
          before { subject.employee_type = "Reporter" }

          it "creates a Reporter" do
            expect do
              subject.save
            end.to change(Reporter, :count).by(1)
          end

          it "sets employee_id" do
            expect(subject.employee_id).to be_nil
            subject.save
            subject.reload
            expect(subject.employee_id).to eq(Employee.last.id)
          end
        end

        context "with employee_type of 'Reviewer'" do
          before { subject.employee_type = "Reviewer" }

          it "creates a Reviewer" do
            expect do
              subject.save
            end.to change(Reviewer, :count).by(1)
          end

          it "sets employee_id" do
            expect(subject.employee_id).to be_nil
            subject.save
            subject.reload
            expect(subject.employee_id).to eq(Employee.last.id)
          end
        end

        context "with employee_type of 'Worker'" do
          before { subject.employee_type = "Worker" }

          it "creates a Worker" do
            expect do
              subject.save
            end.to change(Worker, :count).by(1)
          end

          it "sets employee_id" do
            expect(subject.employee_id).to be_nil
            subject.save
            subject.reload
            expect(subject.employee_id).to eq(Employee.last.id)
          end
        end
      end
    end

    context "for an existing User" do
      let(:user) { Fabricate(:user) }

      before do
        user.name = "New Name"
        user.employee_type = "Reviewer"
      end

      describe "saving" do
        it "doesn't create an Employee" do
          expect do
            user.save
          end.not_to change(Employee, :count)
        end
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
end
