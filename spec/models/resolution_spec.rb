# frozen_string_literal: true

require "rails_helper"

RSpec.describe Resolution, type: :model do
  let(:worker) { Fabricate(:user_worker) }
  let(:issue) { Fabricate(:issue) }

  before do
    @issue = Resolution.new(issue_id: issue.id, user_id: worker.id)
  end

  subject { @issue }

  it { is_expected.to respond_to(:issue_id) }
  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:approved) }

  it { is_expected.to belong_to(:issue) }
  it { is_expected.to belong_to(:user) }

  it { is_expected.to validate_presence_of(:issue_id) }
  it { is_expected.to validate_presence_of(:user_id) }

  # CLASS

  describe ".pending" do
    before do
      Fabricate(:approved_resolution)
      Fabricate(:disapproved_resolution)
    end

    it "returns resolutions with approved as false" do
      resolution = Fabricate(:pending_resolution)
      expect(Resolution.pending).to eq([resolution])
    end
  end

  describe ".disapproved" do
    before do
      Fabricate(:approved_resolution)
      Fabricate(:pending_resolution)
    end

    it "returns resolutions with approved as false" do
      resolution = Fabricate(:disapproved_resolution)
      expect(Resolution.disapproved).to eq([resolution])
    end
  end

  describe ".approved" do
    before do
      Fabricate(:disapproved_resolution)
      Fabricate(:pending_resolution)
    end

    it "returns resolutions with approved as false" do
      resolution = Fabricate(:approved_resolution)
      expect(Resolution.approved).to eq([resolution])
    end
  end

  # INSTANCE

  describe "#approve" do
    context "when pending" do
      let(:resolution) { Fabricate(:pending_resolution) }

      it "changes approved to true" do
        expect do
          resolution.approve
          resolution.reload
        end.to change(resolution, :approved).to(true)
      end

      it "runs issue.close" do
        expect(resolution.issue).to receive(:close)
        resolution.approve
      end

      it "returns true" do
        expect(resolution.approve).to eq(true)
      end
    end

    context "when disapproved" do
      let(:resolution) { Fabricate(:disapproved_resolution) }

      it "changes approved to true" do
        expect do
          resolution.approve
          resolution.reload
        end.to change(resolution, :approved).to(true)
      end

      it "runs issue.close" do
        expect(resolution.issue).to receive(:close)
        resolution.approve
      end

      it "returns true" do
        expect(resolution.approve).to eq(true)
      end
    end

    context "when approved" do
      let(:resolution) { Fabricate(:approved_resolution) }

      it "doesn't change resolution" do
        expect do
          resolution.approve
          resolution.reload
        end.not_to change(resolution, :approved)
      end

      it "runs issue.close" do
        expect(resolution.issue).to receive(:close)
        resolution.approve
      end

      it "returns true" do
        expect(resolution.approve).to eq(true)
      end
    end

    context "when resolution is invalid" do
      let(:resolution) { Fabricate(:pending_resolution) }

      before { resolution.user_id = nil }

      it "doesn't change resolution" do
        expect do
          resolution.approve
          resolution.reload
        end.not_to change(resolution, :approved)
      end

      it "doesn't run issue.close" do
        expect(resolution.issue).not_to receive(:close)
        resolution.approve
      end

      it "returns false" do
        expect(resolution.approve).to eq(false)
      end
    end

    context "when resolution's issue is invalid" do
      let(:resolution) { Fabricate(:pending_resolution) }

      before { resolution.issue.user_id = nil }

      it "doesn't change resolution" do
        expect do
          resolution.approve
          resolution.reload
        end.not_to change(resolution, :approved)
      end

      it "doesn't run issue.close" do
        expect(resolution.issue).not_to receive(:close)
        resolution.approve
      end

      it "returns false" do
        expect(resolution.approve).to eq(false)
      end
    end
  end

  describe "#disapprove" do
    context "when pending" do
      let(:resolution) { Fabricate(:pending_resolution) }

      it "changes approved to false" do
        expect do
          resolution.disapprove
          resolution.reload
        end.to change(resolution, :approved).to(false)
      end

      it "runs issue.open" do
        expect(resolution.issue).to receive(:open)
        resolution.disapprove
      end

      it "returns true" do
        expect(resolution.approve).to eq(true)
      end
    end

    context "when approved" do
      let(:resolution) { Fabricate(:approved_resolution) }

      it "changes approved to false" do
        expect do
          resolution.disapprove
          resolution.reload
        end.to change(resolution, :approved).to(false)
      end

      it "runs issue.open" do
        expect(resolution.issue).to receive(:open)
        resolution.disapprove
      end

      it "returns true" do
        expect(resolution.approve).to eq(true)
      end
    end

    context "when disapproved" do
      let(:resolution) { Fabricate(:disapproved_resolution) }

      it "doesn't change resolution" do
        expect do
          resolution.disapprove
          resolution.reload
        end.not_to change(resolution, :approved)
      end

      it "runs issue.open" do
        expect(resolution.issue).to receive(:open)
        resolution.disapprove
      end

      it "returns true" do
        expect(resolution.approve).to eq(true)
      end
    end

    context "when resolution is invalid" do
      let(:resolution) { Fabricate(:pending_resolution) }

      before { resolution.user_id = nil }

      it "doesn't change resolution" do
        expect do
          resolution.disapprove
          resolution.reload
        end.not_to change(resolution, :approved)
      end

      it "doesn't run issue.open" do
        expect(resolution.issue).not_to receive(:open)
        resolution.disapprove
      end

      it "returns false" do
        expect(resolution.approve).to eq(false)
      end
    end

    context "when resolution's issue is invalid" do
      let(:resolution) { Fabricate(:pending_resolution) }

      before { resolution.issue.user_id = nil }

      it "doesn't change resolution" do
        expect do
          resolution.disapprove
          resolution.reload
        end.not_to change(resolution, :approved)
      end

      it "doesn't run issue.open" do
        expect(resolution.issue).not_to receive(:open)
        resolution.disapprove
      end

      it "returns false" do
        expect(resolution.approve).to eq(false)
      end
    end
  end

  describe "#pending?" do
    context "when approved is nil" do
      let(:resolution) { Fabricate(:resolution, approved: nil) }

      it "returns true" do
        expect(resolution.pending?).to eq(true)
      end
    end

    context "when approved is false" do
      let(:resolution) { Fabricate(:resolution, approved: false) }

      it "returns false" do
        expect(resolution.pending?).to eq(false)
      end
    end

    context "when approved is true" do
      let(:resolution) { Fabricate(:resolution, approved: true) }

      it "returns false" do
        expect(resolution.pending?).to eq(false)
      end
    end
  end

  describe "#disapproved?" do
    context "when approved is nil" do
      let(:resolution) { Fabricate(:resolution, approved: nil) }

      it "returns false" do
        expect(resolution.disapproved?).to eq(false)
      end
    end

    context "when approved is false" do
      let(:resolution) { Fabricate(:resolution, approved: false) }

      it "returns true" do
        expect(resolution.disapproved?).to eq(true)
      end
    end

    context "when approved is true" do
      let(:resolution) { Fabricate(:resolution, approved: true) }

      it "returns false" do
        expect(resolution.disapproved?).to eq(false)
      end
    end
  end

  describe "#status" do
    let(:resolution) { Fabricate(:resolution) }

    context "when pending" do
      before { allow(resolution).to receive(:pending?) { true } }
      before { allow(resolution).to receive(:approved?) { false } }

      it "returns 'pending'" do
        expect(resolution.status).to eq("pending")
      end
    end

    context "when approved" do
      before { allow(resolution).to receive(:pending?) { false } }
      before { allow(resolution).to receive(:approved?) { true } }

      it "returns 'approved'" do
        expect(resolution.status).to eq("approved")
      end
    end

    context "when disapproved" do
      before { allow(resolution).to receive(:pending?) { false } }
      before { allow(resolution).to receive(:approved?) { false } }

      it "returns 'disapproved'" do
        expect(resolution.status).to eq("disapproved")
      end
    end
  end
end
