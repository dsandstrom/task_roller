# frozen_string_literal: true

require "rails_helper"

RSpec.describe SearchResult, type: :model do
  before { @search_result = SearchResult.new }

  subject { @search_result }

  it { is_expected.to respond_to(:summary) }
  it { is_expected.to respond_to(:description) }
  it { is_expected.to respond_to(:closed) }
  it { is_expected.to respond_to(:opened_at) }
  it { is_expected.to respond_to(:type_id) }
  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:project_id) }
  it { is_expected.to respond_to(:issue_id) }
  it { is_expected.to respond_to(:class_name) }
  it { is_expected.to respond_to(:created_at) }
  it { is_expected.to respond_to(:updated_at) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:project) }
  it { is_expected.to respond_to(:category) }

  it { is_expected.to belong_to(:issue_type) }
  it { is_expected.to belong_to(:task_type) }

  it { is_expected.to belong_to(:issue) }

  it { is_expected.to have_many(:task_assignees) }
  it { is_expected.to have_many(:assignees) }

  # CLASS

  # INSTANCE

  describe "#issue?" do
    context "when class_name is 'Issue'" do
      before { subject.class_name = "Issue" }

      it "returns true" do
        expect(subject.issue?).to eq(true)
      end
    end

    context "when class_name is 'Task'" do
      before { subject.class_name = "Task" }

      it "returns false" do
        expect(subject.issue?).to eq(false)
      end
    end

    context "when class_name is something else" do
      before { subject.class_name = "Something Else" }

      it "returns false" do
        expect(subject.issue?).to eq(false)
      end
    end
  end

  describe "#task?" do
    context "when class_name is 'Issue'" do
      before { subject.class_name = "Issue" }

      it "returns false" do
        expect(subject.task?).to eq(false)
      end
    end

    context "when class_name is 'Task'" do
      before { subject.class_name = "Task" }

      it "returns true" do
        expect(subject.task?).to eq(true)
      end
    end

    context "when class_name is something else" do
      before { subject.class_name = "Something Else" }

      it "returns false" do
        expect(subject.task?).to eq(false)
      end
    end
  end

  describe "#heading" do
    let(:task) { Fabricate(:task) }

    before do
      subject.class_name = "Task"
      subject.id = task.id
      subject.summary = task.summary
    end

    context "when a summary" do
      it "returns class_name and short_summary" do
        expect(subject.heading)
          .to eq("Task \##{subject.id}: #{subject.summary}")
      end
    end

    context "when summary is blank" do
      before { subject.summary = "" }

      it "returns nil" do
        expect(subject.heading).to be_nil
      end
    end
  end

  describe "#short_summary" do
    let(:short_summary_length) { 70 }

    context "when summary is short" do
      before { subject.summary = "short" }

      it "lets it be" do
        expect(subject.short_summary).to eq("short")
      end
    end

    context "when summary is 1 too long" do
      before { subject.summary = "#{'a' * short_summary_length}b" }

      it "truncates it" do
        expect(subject.short_summary)
          .to eq("#{'a' * (short_summary_length - 3)}...")
      end
    end
  end

  describe "#status" do
    it "returns only nil for now" do
      expect(subject.status).to be_nil
    end
  end
end
