# frozen_string_literal: true

require "rails_helper"

RSpec.describe IssueConnection, type: :model do
  let(:source) { Fabricate(:issue) }
  let(:target) { Fabricate(:issue) }

  before do
    @issue_connection =
      IssueConnection.new(source_id: source.id, target_id: target.id)
  end

  subject { @issue_connection }

  it { is_expected.to be_valid }
  it { expect(subject.type).to eq("IssueConnection") }

  it { is_expected.to belong_to(:source) }
  it { is_expected.to belong_to(:target) }

  describe "#target_options" do
    context "when source has a project" do
      context "with other issues" do
        it "returns source project's other issues" do
          issue = Fabricate(:issue, project: source.project)
          expect(subject.target_options).to eq([issue])
        end
      end

      context "with no other issues" do
        it "returns source project's other issues" do
          expect(subject.target_options).to eq([])
        end
      end
    end

    context "when source doesn't have a project" do
      before { subject.source.project = nil }

      it "returns nil" do
        expect(subject.target_options).to be_nil
      end
    end

    context "when source doesn't have a category" do
      before { source.category.destroy }

      it "returns nil" do
        expect(subject.target_options).to be_nil
      end
    end

    context "when source nil" do
      before { subject.source = nil }

      it "returns nil" do
        expect(subject.target_options).to be_nil
      end
    end

    context "when source id is nil" do
      before { subject.source.id = nil }

      it "returns nil" do
        expect(subject.target_options).to be_nil
      end
    end
  end
end
