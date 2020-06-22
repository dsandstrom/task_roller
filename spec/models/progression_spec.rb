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

  it { is_expected.to be_valid }

  it { is_expected.to validate_presence_of(:task_id) }
  it { is_expected.to validate_presence_of(:user_id) }

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
end
