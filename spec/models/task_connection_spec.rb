# frozen_string_literal: true

require "rails_helper"

RSpec.describe TaskConnection, type: :model do
  let(:source) { Fabricate(:task) }
  let(:target) { Fabricate(:task) }

  before do
    @task_connection =
      TaskConnection.new(source_id: source.id, target_id: target.id)
  end

  subject { @task_connection }

  it { is_expected.to be_valid }
  it { expect(subject.type).to eq("TaskConnection") }

  it { is_expected.to belong_to(:source) }
  it { is_expected.to belong_to(:target) }
end
