# frozen_string_literal: true

require "rails_helper"

RSpec.describe TaskAssignee, type: :model do
  let(:task) { Fabricate(:task) }
  let(:worker) { Fabricate(:user_worker) }

  before do
    @task_assignee = TaskAssignee.new(task_id: task.id, assignee_id: worker.id)
  end

  subject { @task_assignee }

  it { is_expected.to respond_to(:task_id) }
  it { is_expected.to respond_to(:assignee_id) }

  it { is_expected.to belong_to(:task) }
  it { is_expected.to belong_to(:assignee) }

  it { is_expected.to be_valid }

  it { is_expected.to validate_uniqueness_of(:assignee_id).scoped_to(:task_id) }
end
