# frozen_string_literal: true

require "rails_helper"

RSpec.describe TaskClosure, type: :model do
  let(:task) { Fabricate(:task) }
  let(:user) { Fabricate(:user_reviewer) }

  before do
    @task_closure = TaskClosure.new(task_id: task.id, user_id: user.id)
  end

  subject { @task_closure }

  it { is_expected.to respond_to(:task_id) }
  it { is_expected.to respond_to(:user_id) }

  it { is_expected.to be_valid }

  it { is_expected.to validate_presence_of(:task_id) }
  it { is_expected.to validate_presence_of(:user_id) }

  it { is_expected.to belong_to(:task) }
  it { is_expected.to respond_to(:user) }
end
