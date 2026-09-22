require "rails_helper"

RSpec.describe SearchSubscription, type: :model do
  let(:user) { Fabricate(:user) }

  before do
    @search_subscription =
      SearchSubscription.new(user_id: user.id, term: "Search")
  end

  subject { @search_subscription }

  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:include_issues) }
  it { is_expected.to respond_to(:include_tasks) }
  it { is_expected.to respond_to(:term) }
  it { is_expected.to respond_to(:issue_type_id) }
  it { is_expected.to respond_to(:task_type_id) }
  it { is_expected.to respond_to(:issue_status) }
  it { is_expected.to respond_to(:task_status) }
  it { is_expected.to respond_to(:source_user_id) }
  it { is_expected.to respond_to(:category_id) }
  it { is_expected.to respond_to(:project_id) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:source_user).optional }
  it { is_expected.to belong_to(:category).optional }
  it { is_expected.to belong_to(:project).optional }
  it { is_expected.to belong_to(:issue_type).optional }
  it { is_expected.to belong_to(:task_type).optional }

  it { is_expected.to be_valid }

  it { is_expected.to validate_length_of(:term).is_at_most(50) }

  describe "#validates" do
    describe "any_search_parameter" do
      before do
        subject.term = nil
      end

      context "when term is not set" do
        it { is_expected.not_to be_valid }
      end

      context "when only issue_type_id is set" do
        before do
          subject.issue_type_id = Fabricate(:issue_type).id
        end

        context "and include_issues is true" do
          before do
            subject.include_issues = true
          end

          it { is_expected.to be_valid }
        end

        context "and include_issues is false" do
          before do
            subject.include_issues = false
          end

          it { is_expected.not_to be_valid }
        end
      end

      context "when only task_type_id is set" do
        before do
          subject.task_type_id = Fabricate(:task_type).id
        end

        context "and include_tasks is true" do
          before do
            subject.include_tasks = true
          end

          it { is_expected.to be_valid }
        end

        context "and include_tasks is false" do
          before do
            subject.include_tasks = false
          end

          it { is_expected.not_to be_valid }
        end
      end

      context "when only issue_status is set" do
        before do
          subject.issue_status = "pending"
        end

        it { is_expected.to be_valid }
      end

      context "when only task_status is set" do
        before do
          subject.task_status = "assigned"
        end

        it { is_expected.to be_valid }
      end

      context "when only source_user_id is set" do
        before do
          subject.source_user_id = Fabricate(:user).id
        end

        it { is_expected.to be_valid }
      end

      context "when only category_id is set" do
        before do
          subject.category_id = Fabricate(:category).id
        end

        it { is_expected.to be_valid }
      end

      context "when only project_id is set" do
        before do
          subject.project_id = Fabricate(:project).id
        end

        it { is_expected.to be_valid }
      end
    end

    describe "include_issues_or_tasks" do
      before do
        subject.include_issues = false
        subject.include_tasks = false
      end

      context "when both include_issues and include_tasks are false" do
        it { is_expected.not_to be_valid }
      end

      context "when include_issues is true" do
        before do
          subject.include_issues = true
        end

        it { is_expected.to be_valid }
      end

      context "when include_tasks is true" do
        before do
          subject.include_tasks = true
        end

        it { is_expected.to be_valid }
      end
    end
  end

  describe "#toggle" do
    context "for an active SearchSubscription" do
      let(:search_subscription) { Fabricate(:search_subscription) }

      it "changes active to false" do
        expect do
          search_subscription.toggle
          search_subscription.reload
        end.to change(search_subscription, :active).to(false)
      end
    end

    context "for an inactive SearchSubscription" do
      let(:search_subscription) { Fabricate(:inactive_search_subscription) }

      it "changes active to true" do
        expect do
          search_subscription.toggle
          search_subscription.reload
        end.to change(search_subscription, :active).to(true)
      end
    end
  end
end
