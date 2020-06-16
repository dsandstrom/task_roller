# frozen_string_literal: true

require "rails_helper"

RSpec.describe Issue, type: :model do
  let(:reporter) { Fabricate(:user_reporter) }
  let(:project) { Fabricate(:project) }
  let(:issue_type) { Fabricate(:issue_type) }

  before do
    @issue = Issue.new(summary: "Summary", description: "Description",
                       user_id: reporter.id, project_id: project.id,
                       issue_type_id: issue_type.id)
  end

  subject { @issue }

  it { is_expected.to be_valid }

  it { is_expected.to respond_to(:summary) }
  it { is_expected.to respond_to(:description) }
  it { is_expected.to respond_to(:closed) }
  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:issue_type_id) }
  it { is_expected.to respond_to(:project_id) }
  it { is_expected.to respond_to(:category) }

  it { is_expected.to validate_presence_of(:summary) }
  it { is_expected.to validate_length_of(:summary).is_at_most(200) }
  it { is_expected.to validate_presence_of(:description) }
  it { is_expected.to validate_length_of(:description).is_at_most(2000) }
  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_presence_of(:issue_type_id) }
  it { is_expected.to validate_presence_of(:project_id) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:issue_type) }
  it { is_expected.to belong_to(:project) }
  it { is_expected.to have_many(:tasks) }
  it { is_expected.to have_many(:comments).dependent(:destroy) }

  # CLASS

  describe ".all_open" do
    context "when no issues" do
      before { Issue.destroy_all }

      it "returns []" do
        expect(Issue.all_open).to eq([])
      end
    end

    context "when one open, one closed issues" do
      let!(:issue) { Fabricate(:open_issue) }

      before do
        Fabricate(:closed_issue)
      end

      it "returns the open one" do
        expect(Issue.all_open).to eq([issue])
      end
    end
  end

  describe ".all_closed" do
    context "when no issues" do
      before { Issue.destroy_all }

      it "returns []" do
        expect(Issue.all_closed).to eq([])
      end
    end

    context "when one closed, one closed issues" do
      let!(:issue) { Fabricate(:closed_issue) }

      before do
        Fabricate(:open_issue)
      end

      it "returns the closed one" do
        expect(Issue.all_closed).to eq([issue])
      end
    end
  end

  # INSTANCE

  describe "#tasks" do
    let(:issue) { Fabricate(:issue) }

    context "when destroying task" do
      it "nullifies tasks" do
        task = Fabricate(:task, issue: issue)

        expect do
          issue.destroy
          task.reload
        end.to change(task, :issue_id).to(nil)
      end
    end
  end

  describe "#description_html" do
    context "when description is _foo_" do
      before { subject.description = "_foo_" }

      it "adds em tags" do
        expect(subject.description_html).to eq("<p><em>foo</em></p>\n")
      end
    end
  end

  describe "#short_summary" do
    let(:short_summary_length) { 100 }

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

  describe "#open?" do
    context "closed is false" do
      before { subject.closed = false }

      it "returns true" do
        expect(subject.open?).to eq(true)
      end
    end

    context "closed is true" do
      before { subject.closed = true }

      it "returns false" do
        expect(subject.open?).to eq(false)
      end
    end
  end
end
