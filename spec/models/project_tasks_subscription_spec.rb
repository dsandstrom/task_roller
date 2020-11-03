# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProjectTasksSubscription, type: :model do
  let(:project) { Fabricate(:project) }
  let(:user) { Fabricate(:user_reporter) }

  before do
    @project_tasks_subscription =
      ProjectTasksSubscription.new(user_id: user.id, project_id: project.id)
  end

  subject { @project_tasks_subscription }

  it { is_expected.to be_valid }

  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_presence_of(:project_id) }

  context "when a duplicate" do
    it "shouldn't be valid" do
      subject.dup.save
      expect(subject).not_to be_valid
    end
  end

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:project) }
end
