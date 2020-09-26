# frozen_string_literal: true

require "rails_helper"

RSpec.describe TaskConnection, type: :model do
  let(:project) { Fabricate(:project) }
  let(:source) { Fabricate(:task, project: project) }
  let(:target) { Fabricate(:task, project: project) }

  before do
    @task_connection =
      TaskConnection.new(source_id: source.id, target_id: target.id)
  end

  subject { @task_connection }

  it { is_expected.to be_valid }
  it { expect(subject.type).to eq("TaskConnection") }

  it { is_expected.to belong_to(:source) }
  it { is_expected.to belong_to(:target) }

  describe "#target_options" do
    let(:source) { Fabricate(:task) }
    let(:task_connection) do
      Fabricate.build(:task_connection, source: source)
    end

    context "when source has a project" do
      context "with other tasks" do
        it "returns source project's other tasks" do
          task = Fabricate(:task, project: source.project)
          expect(task_connection.target_options).to eq([task])
        end
      end

      context "with no other tasks" do
        it "returns source project's other tasks" do
          expect(task_connection.target_options).to eq([])
        end
      end
    end

    context "when source doesn't have a project" do
      before { task_connection.source.project = nil }

      it "returns nil" do
        expect(task_connection.target_options).to be_nil
      end
    end

    context "when source nil" do
      before { task_connection.source = nil }

      it "returns nil" do
        expect(task_connection.target_options).to be_nil
      end
    end

    context "when source id is nil" do
      before { task_connection.source.id = nil }

      it "returns nil" do
        expect(task_connection.target_options).to be_nil
      end
    end
  end
end
