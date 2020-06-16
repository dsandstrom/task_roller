# frozen_string_literal: true

require "rails_helper"

RSpec.describe Task, type: :model do
  let(:worker) { Fabricate(:user_worker) }
  let(:project) { Fabricate(:project) }
  let(:task_type) { Fabricate(:task_type) }

  before do
    @task = Task.new(summary: "Summary", description: "Description",
                     user_id: worker.id, project_id: project.id,
                     task_type_id: task_type.id)
  end

  subject { @task }

  it { is_expected.to respond_to(:summary) }
  it { is_expected.to respond_to(:description) }
  it { is_expected.to respond_to(:closed) }
  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:task_type_id) }
  it { is_expected.to respond_to(:project_id) }
  it { is_expected.to respond_to(:category) }

  it { is_expected.to be_valid }

  it { is_expected.to validate_presence_of(:summary) }
  it { is_expected.to validate_length_of(:summary).is_at_most(200) }
  it { is_expected.to validate_presence_of(:description) }
  it { is_expected.to validate_length_of(:description).is_at_most(2000) }
  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_presence_of(:task_type_id) }
  it { is_expected.to validate_presence_of(:project_id) }
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:task_type) }
  it { is_expected.to belong_to(:project) }
  it { is_expected.to belong_to(:issue) }
  it { is_expected.to have_many(:task_assignees) }
  it { is_expected.to have_many(:assignees) }
  it { is_expected.to have_many(:comments).dependent(:destroy) }

  # CLASS

  describe ".all_open" do
    context "when no tasks" do
      before { Task.destroy_all }

      it "returns []" do
        expect(Task.all_open).to eq([])
      end
    end

    context "when one open, one closed tasks" do
      let!(:task) { Fabricate(:open_task) }

      before do
        Fabricate(:closed_task)
      end

      it "returns the open one" do
        expect(Task.all_open).to eq([task])
      end
    end
  end

  describe ".all_closed" do
    context "when no tasks" do
      before { Task.destroy_all }

      it "returns []" do
        expect(Task.all_closed).to eq([])
      end
    end

    context "when one closed, one closed tasks" do
      let!(:task) { Fabricate(:closed_task) }

      before do
        Fabricate(:open_task)
      end

      it "returns the closed one" do
        expect(Task.all_closed).to eq([task])
      end
    end
  end

  # INSTANCE

  describe "#task_assignees" do
    let(:task) { Fabricate(:task) }

    context "when destroying task" do
      before { Fabricate(:task_assignee, task: task) }

      it "destroys it's task_assignees" do
        expect do
          task.destroy
        end.to change(TaskAssignee, :count).by(-1)
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
