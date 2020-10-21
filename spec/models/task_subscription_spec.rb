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

  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_presence_of(:task_id) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:task) }
end
