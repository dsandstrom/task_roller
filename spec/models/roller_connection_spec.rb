# frozen_string_literal: true

require "rails_helper"

RSpec.describe RollerConnection, type: :model do
  let(:project) { Fabricate(:project) }
  let(:source) { Fabricate(:issue, project: project) }
  let(:target) { Fabricate(:issue, project: project) }

  before do
    @roller_connection =
      IssueConnection.new(source_id: source.id, target_id: target.id)
  end

  subject { @roller_connection }

  it { is_expected.to respond_to(:type) }
  it { is_expected.to respond_to(:source_id) }
  it { is_expected.to respond_to(:target_id) }
  it { is_expected.to respond_to(:scheme) }

  it { is_expected.to be_valid }
  it { is_expected.to validate_presence_of(:source_id) }
  it { is_expected.to validate_presence_of(:target_id) }

  describe "#validate" do
    describe "#target_has_options" do
      context "when source's project has other issues" do
        it { expect(subject).to be_valid }
      end

      context "when source's project has no other issues" do
        before { allow(subject).to receive(:target_options) { nil } }

        it { expect(subject).not_to be_valid }
      end
    end

    describe "#matching_projects" do
      context "when source and target have the same project" do
        it { expect(subject).to be_valid }
      end

      context "when source and target don't have the same project" do
        before { subject.target.project = Fabricate(:project) }

        it { expect(subject).not_to be_valid }
      end

      context "when source and target don't projects" do
        before do
          subject.source.project = nil
          subject.target.project = nil
        end

        it { expect(subject).not_to be_valid }
      end

      context "when source blank" do
        before { subject.source = nil }

        it { expect(subject).not_to be_valid }
      end

      context "when target blank" do
        before { subject.target = nil }

        it { expect(subject).not_to be_valid }
      end
    end
  end
end
