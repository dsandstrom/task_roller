# frozen_string_literal: true

require "rails_helper"

RSpec.describe TaskComment, type: :model do
  let(:user) { Fabricate(:user_worker) }
  let(:task) { Fabricate(:task) }

  before do
    @task_comment =
      TaskComment.new(roller_id: task.id, user_id: user.id, body: "Comment")
  end

  subject { @task_comment }

  it { is_expected.to be_a(RollerComment) }

  it { expect(subject.type).to eq("TaskComment") }

  it { is_expected.to belong_to(:task) }

  it { is_expected.to be_valid }
  it { is_expected.to validate_presence_of(:roller_id) }
end
