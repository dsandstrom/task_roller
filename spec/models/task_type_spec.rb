# frozen_string_literal: true

require "rails_helper"

RSpec.describe TaskType, type: :model do
  before do
    @task_type =
      TaskType.new(name: "Task Type Name", icon: "bulb", color: "blue")
  end

  subject { @task_type }

  it { is_expected.to be_a(RollerType) }
  it { expect(subject.type).to eq("TaskType") }
  it { is_expected.to be_valid }
end
