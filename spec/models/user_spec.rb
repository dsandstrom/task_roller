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

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_uniqueness_of(:email).case_insensitive }

  describe "on create" do
    context "for a valid employee_type" do
      %w[Reporter Reviewer Worker].each do |employee_type|
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

  describe ".reporters" do
    it "includes only Reporters" do
      user_reporter = Fabricate(:user_reporter)
      Fabricate(:user_reviewer)
      Fabricate(:user_worker)

      expect(User.reporters).to eq([user_reporter])
    end
  end

  describe ".reviewers" do
    it "includes only Reviewers" do
      user_reviewer = Fabricate(:user_reviewer)
      Fabricate(:user_reporter)
      Fabricate(:user_worker)

      expect(User.reviewers).to eq([user_reviewer])
    end
  end

  describe ".workers" do
    it "includes only Workers" do
      user_worker = Fabricate(:user_worker)
      Fabricate(:user_reporter)
      Fabricate(:user_reviewer)

      expect(User.workers).to eq([user_worker])
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
end
