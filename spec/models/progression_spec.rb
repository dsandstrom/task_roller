# frozen_string_literal: true

require "rails_helper"

RSpec.describe Progression, type: :model do
  let(:worker) { Fabricate(:user_worker) }
  let(:task) { Fabricate(:task) }

  before do
    @progression = Progression.new(task_id: task.id, user_id: worker.id)
  end

  subject { @progression }

  it { is_expected.to respond_to(:task_id) }
  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:finished) }

  it { is_expected.to belong_to(:task) }
  it { is_expected.to belong_to(:user) }

  it { is_expected.to validate_presence_of(:task_id) }
  it { is_expected.to validate_presence_of(:user_id) }

  describe "uniqueness" do
    context "when user has no other progressions" do
      it { is_expected.to be_valid }
    end

    context "when user has a finished progression for the task" do
      before { Fabricate(:finished_progression, user: worker, task: task) }

      it { is_expected.to be_valid }
    end

    context "when user has an unfinished progression for the task" do
      before { Fabricate(:unfinished_progression, user: worker, task: task) }

      it { is_expected.not_to be_valid }
    end

    context "when user has an unfinished progression for another task" do
      before { Fabricate(:unfinished_progression, user: worker) }

      it { is_expected.to be_valid }
    end

    context "when progression is saved" do
      before { subject.save }

      it { is_expected.to be_valid }
    end
  end

  # CLASS

  describe ".unfinished" do
    before { Fabricate(:finished_progression) }

    it "returns progressions with finished as false" do
      progression = Fabricate(:unfinished_progression)
      expect(Progression.unfinished).to eq([progression])
    end
  end

  describe ".finished" do
    before { Fabricate(:unfinished_progression) }

    it "returns progressions with finished as false" do
      progression = Fabricate(:finished_progression)
      expect(Progression.finished).to eq([progression])
    end
  end

  # INSTANCE

  describe "#finish" do
    let(:task) { Fabricate(:open_task) }

    context "when unfinished" do
      it "changes it's finished to true" do
        progression = Fabricate(:unfinished_progression, task: task)

        expect do
          progression.finish
          progression.reload
        end.to change(progression, :finished).to(true)
      end
    end

    context "when finished" do
      it "doesn't change finished" do
        progression = Fabricate(:finished_progression, task: task)

        expect do
          progression.finish
          progression.reload
        end.not_to change(progression, :finished)
      end
    end
  end
end
