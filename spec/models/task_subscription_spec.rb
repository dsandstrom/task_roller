# frozen_string_literal: true

require "rails_helper"

RSpec.describe TaskSubscription, type: :model do
  let(:task) { Fabricate(:task) }
  let(:user) { Fabricate(:user_reporter) }

  before do
    @task_subscription = TaskSubscription.new(user_id: user.id,
                                              task_id: task.id)
  end

  subject { @task_subscription }

  it { is_expected.to be_valid }
  it { is_expected.to respond_to(:heading) }

  it { is_expected.to belong_to(:task).required }
  it { is_expected.to belong_to(:user).required }

  context "when a duplicate" do
    it "shouldn't be valid" do
      subject.dup.save
      expect(subject).not_to be_valid
    end
  end

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:task) }
end
