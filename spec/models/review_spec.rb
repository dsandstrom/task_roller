# frozen_string_literal: true

require "rails_helper"
require File.expand_path("../support/task_helpers", __dir__)

RSpec.describe Review, type: :model do
  let(:worker) { Fabricate(:user_worker) }
  let(:task) { Fabricate(:task) }

  before do
    @review = Review.new(task_id: task.id, user_id: worker.id)
  end

  subject { @review }

  it { is_expected.to respond_to(:task_id) }
  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:approved) }

  it { is_expected.to belong_to(:task) }
  it { is_expected.to belong_to(:user) }

  it { is_expected.to validate_presence_of(:task_id) }
  it { is_expected.to validate_presence_of(:user_id) }

  describe "uniqueness" do
    context "when task has no other reviews" do
      it { is_expected.to be_valid }
    end

    context "for a pending review" do
      context "when saved" do
        before { subject.save }

        it { is_expected.to be_valid }
      end

      context "when it's task already has a pending review" do
        before { Fabricate(:pending_review, task: task) }

        it { is_expected.not_to be_valid }
      end

      context "when it's task has an approved review" do
        before { Fabricate(:approved_review, task: task) }

        it { is_expected.not_to be_valid }
      end

      context "when it's task has a disapproved review" do
        before { Fabricate(:disapproved_review, task: task) }

        it { is_expected.to be_valid }
      end

      context "when it's task an out of date pending review" do
        before do
          Timecop.freeze(1.day.ago) do
            Fabricate(:pending_review, task: task)
          end
          task.open
        end

        it { is_expected.to be_valid }
      end

      context "when it's task an out of date approved review" do
        before do
          Timecop.freeze(1.day.ago) do
            Fabricate(:approved_review, task: task)
          end
          task.open
        end

        it { is_expected.to be_valid }
      end

      context "when it's task has an out of date disapproved review" do
        before do
          Timecop.freeze(1.day.ago) do
            Fabricate(:disapproved_review, task: task)
          end
          task.open
        end

        it { is_expected.to be_valid }
      end
    end

    context "for a approved review" do
      before { subject.approved = true }

      context "when saved" do
        before { subject.save }

        it { is_expected.to be_valid }
      end

      context "when it's task already has a approved review" do
        before { Fabricate(:approved_review, task: task) }

        it { is_expected.not_to be_valid }
      end

      context "when it's task has a pending review" do
        before { Fabricate(:pending_review, task: task) }

        it { is_expected.not_to be_valid }
      end

      context "when it's task has a disapproved review" do
        before { Fabricate(:disapproved_review, task: task) }

        it { is_expected.to be_valid }
      end

      context "when it's task an out of date pending review" do
        before do
          Timecop.freeze(1.day.ago) do
            Fabricate(:pending_review, task: task)
          end
          task.open
        end

        it { is_expected.to be_valid }
      end

      context "when it's task an out of date approved review" do
        before do
          Timecop.freeze(1.day.ago) do
            Fabricate(:approved_review, task: task)
          end
          task.open
        end

        it { is_expected.to be_valid }
      end

      context "when it's task has an out of date disapproved review" do
        before do
          Timecop.freeze(1.day.ago) do
            Fabricate(:disapproved_review, task: task)
          end
          task.open
        end

        it { is_expected.to be_valid }
      end
    end

    context "for a disapproved review" do
      before { subject.approved = false }

      context "when saved" do
        before { subject.save }

        it { is_expected.to be_valid }
      end

      context "when it's task already has a disapproved review" do
        before { Fabricate(:disapproved_review, task: task) }

        it { is_expected.to be_valid }
      end

      context "when it's task has a pending review" do
        before { Fabricate(:pending_review, task: task) }

        it { is_expected.not_to be_valid }
      end

      context "when it's task has an approved review" do
        before { Fabricate(:approved_review, task: task) }

        it { is_expected.not_to be_valid }
      end

      context "when it's task an out of date pending review" do
        before do
          Timecop.freeze(1.day.ago) do
            Fabricate(:pending_review, task: task)
          end
          task.open
        end

        it { is_expected.to be_valid }
      end

      context "when it's task an out of date approved review" do
        before do
          Timecop.freeze(1.day.ago) do
            Fabricate(:approved_review, task: task)
          end
          task.open
        end

        it { is_expected.to be_valid }
      end

      context "when it's task has an out of date disapproved review" do
        before do
          Timecop.freeze(1.day.ago) do
            Fabricate(:disapproved_review, task: task)
          end
          task.open
        end

        it { is_expected.to be_valid }
      end
    end
  end

  # CLASS

  describe ".pending" do
    before do
      Fabricate(:approved_review)
      Fabricate(:disapproved_review)
    end

    it "returns reviews with approved as false" do
      review = Fabricate(:pending_review)
      expect(Review.pending).to eq([review])
    end
  end

  describe ".disapproved" do
    before do
      Fabricate(:approved_review)
      Fabricate(:pending_review)
    end

    it "returns reviews with approved as false" do
      review = Fabricate(:disapproved_review)
      expect(Review.disapproved).to eq([review])
    end
  end

  describe ".approved" do
    before do
      Fabricate(:disapproved_review)
      Fabricate(:pending_review)
    end

    it "returns reviews with approved as false" do
      review = Fabricate(:approved_review)
      expect(Review.approved).to eq([review])
    end
  end

  # INSTANCE

  describe "#approve" do
    context "when pending" do
      let(:review) { Fabricate(:pending_review) }

      it "changes approved to true" do
        expect do
          review.approve
          review.reload
        end.to change(review, :approved).to(true)
      end

      it "runs task.close" do
        task = mock_review_task(review)
        expect(task).to receive(:close)
        review.approve
      end

      it "returns true" do
        expect(review.approve).to eq(true)
      end
    end

    context "when disapproved" do
      let(:review) { Fabricate(:disapproved_review) }

      it "changes approved to true" do
        expect do
          review.approve
          review.reload
        end.to change(review, :approved).to(true)
      end

      it "runs task.close" do
        task = mock_review_task(review)
        expect(task).to receive(:close)
        review.approve
      end

      it "returns true" do
        expect(review.approve).to eq(true)
      end
    end

    context "when approved" do
      let(:review) { Fabricate(:approved_review) }

      it "doesn't change review" do
        expect do
          review.approve
          review.reload
        end.not_to change(review, :approved)
      end

      it "runs task.close" do
        task = mock_review_task(review)
        expect(task).to receive(:close)
        review.approve
      end

      it "returns true" do
        expect(review.approve).to eq(true)
      end
    end

    context "when review is invalid" do
      let(:review) { Fabricate(:pending_review) }

      before { review.user_id = nil }

      it "doesn't change review" do
        expect do
          review.approve
          review.reload
        end.not_to change(review, :approved)
      end

      it "doesn't run task.close" do
        task = mock_review_task(review)
        expect(task).not_to receive(:close)
        review.approve
      end

      it "returns false" do
        expect(review.approve).to eq(false)
      end
    end

    context "when review's task is invalid" do
      let(:review) { Fabricate(:pending_review) }

      before { review.task.user_id = nil }

      it "doesn't change review" do
        expect do
          review.approve
          review.reload
        end.not_to change(review, :approved)
      end

      it "doesn't run task.close" do
        task = mock_review_task(review)
        allow(task).to receive(:valid?) { false }
        expect(task).not_to receive(:close)
        review.approve
      end

      it "returns false" do
        expect(review.approve).to eq(false)
      end
    end
  end

  describe "#disapprove" do
    context "when pending" do
      let(:review) { Fabricate(:pending_review) }

      it "changes approved to false" do
        expect do
          review.disapprove
          review.reload
        end.to change(review, :approved).to(false)
      end

      it "runs task.open" do
        task = mock_review_task(review)
        expect(task).to receive(:open)
        review.disapprove
      end

      it "returns true" do
        expect(review.approve).to eq(true)
      end
    end

    context "when approved" do
      let(:review) { Fabricate(:approved_review) }

      it "changes approved to false" do
        expect do
          review.disapprove
          review.reload
        end.to change(review, :approved).to(false)
      end

      it "runs task.open" do
        task = mock_review_task(review)
        expect(task).to receive(:open)
        review.disapprove
      end

      it "returns true" do
        expect(review.approve).to eq(true)
      end
    end

    context "when disapproved" do
      let(:review) { Fabricate(:disapproved_review) }

      it "doesn't change review" do
        expect do
          review.disapprove
          review.reload
        end.not_to change(review, :approved)
      end

      it "runs task.open" do
        task = mock_review_task(review)
        expect(task).to receive(:open)
        review.disapprove
      end

      it "returns true" do
        expect(review.approve).to eq(true)
      end
    end

    context "when review is invalid" do
      let(:review) { Fabricate(:pending_review) }

      before { review.user_id = nil }

      it "doesn't change review" do
        expect do
          review.disapprove
          review.reload
        end.not_to change(review, :approved)
      end

      it "doesn't run task.open" do
        task = mock_review_task(review)
        expect(task).not_to receive(:open)
        review.disapprove
      end

      it "returns false" do
        expect(review.approve).to eq(false)
      end
    end

    context "when review's task is invalid" do
      let(:review) { Fabricate(:pending_review) }

      before { review.task.user_id = nil }

      it "doesn't change review" do
        expect do
          review.disapprove
          review.reload
        end.not_to change(review, :approved)
      end

      it "doesn't run task.open" do
        task = mock_review_task(review)
        allow(task).to receive(:valid?) { false }
        expect(task).not_to receive(:open)
        review.disapprove
      end

      it "returns false" do
        expect(review.approve).to eq(false)
      end
    end
  end

  describe "#pending?" do
    context "when approved is nil" do
      let(:review) { Fabricate(:review, approved: nil) }

      it "returns true" do
        expect(review.pending?).to eq(true)
      end
    end

    context "when approved is false" do
      let(:review) { Fabricate(:review, approved: false) }

      it "returns false" do
        expect(review.pending?).to eq(false)
      end
    end

    context "when approved is true" do
      let(:review) { Fabricate(:review, approved: true) }

      it "returns false" do
        expect(review.pending?).to eq(false)
      end
    end
  end

  describe "#disapproved?" do
    context "when approved is nil" do
      let(:review) { Fabricate(:review, approved: nil) }

      it "returns false" do
        expect(review.disapproved?).to eq(false)
      end
    end

    context "when approved is false" do
      let(:review) { Fabricate(:review, approved: false) }

      it "returns true" do
        expect(review.disapproved?).to eq(true)
      end
    end

    context "when approved is true" do
      let(:review) { Fabricate(:review, approved: true) }

      it "returns false" do
        expect(review.disapproved?).to eq(false)
      end
    end
  end

  describe "#status" do
    let(:review) { Fabricate(:review) }

    context "when pending" do
      before { allow(review).to receive(:pending?) { true } }
      before { allow(review).to receive(:approved?) { false } }

      it "returns 'pending'" do
        expect(review.status).to eq("pending")
      end
    end

    context "when approved" do
      before { allow(review).to receive(:pending?) { false } }
      before { allow(review).to receive(:approved?) { true } }

      it "returns 'approved'" do
        expect(review.status).to eq("approved")
      end
    end

    context "when disapproved" do
      before { allow(review).to receive(:pending?) { false } }
      before { allow(review).to receive(:approved?) { false } }

      it "returns 'disapproved'" do
        expect(review.status).to eq("disapproved")
      end
    end
  end
end
