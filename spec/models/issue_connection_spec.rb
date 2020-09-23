# frozen_string_literal: true

require "rails_helper"

RSpec.describe IssueConnection, type: :model do
  let(:project) { Fabricate(:project) }
  let(:source) { Fabricate(:issue, project: project) }
  let(:target) { Fabricate(:issue, project: project) }

  before do
    @issue_connection =
      IssueConnection.new(source_id: source.id, target_id: target.id)
  end

  subject { @issue_connection }

  it { is_expected.to be_valid }
  it { expect(subject.type).to eq("IssueConnection") }

  it { is_expected.to belong_to(:source) }
  it { is_expected.to belong_to(:target) }

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
  end

  describe "#target_options" do
    let(:source) { Fabricate(:issue) }
    let(:issue_connection) do
      Fabricate.build(:issue_connection, source: source)
    end

    context "when source has a project" do
      context "with other issues" do
        it "returns source project's other issues" do
          issue = Fabricate(:issue, project: source.project)
          expect(issue_connection.target_options).to eq([issue])
        end
      end

      context "with no other issues" do
        it "returns source project's other issues" do
          expect(issue_connection.target_options).to eq([])
        end
      end
    end

    context "when source doesn't have a project" do
      before { issue_connection.source.project = nil }

      it "returns nil" do
        expect(issue_connection.target_options).to be_nil
      end
    end

    context "when source nil" do
      before { issue_connection.source = nil }

      it "returns nil" do
        expect(issue_connection.target_options).to be_nil
      end
    end

    context "when source id is nil" do
      before { issue_connection.source.id = nil }

      it "returns nil" do
        expect(issue_connection.target_options).to be_nil
      end
    end
  end
end
