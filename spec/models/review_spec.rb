# frozen_string_literal: true

require "rails_helper"

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
end
