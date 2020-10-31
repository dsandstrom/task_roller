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

  describe "#subscribe_user" do
    let(:user) { Fabricate(:user_reviewer) }
    let(:subscriber) { Fabricate(:user_reporter) }
    let(:project) { Fabricate(:project) }

    context "when source and target tasks" do
      # let(:source) { Fabricate(:task, project: project) }
      let(:target) { Fabricate(:task, project: project) }

      context "and source has a user" do
        let(:source) { Fabricate(:task, project: project, user: user) }

        let(:task_connection) do
          Fabricate(:task_connection, source: source, target: target)
        end

        context "that is not subscribed" do
          it "creates a task_subscription for the task user" do
            expect do
              task_connection.subscribe_user
            end.to change(user.task_subscriptions, :count).by(1)
          end
        end

        context "that is already subscribed" do
          before do
            Fabricate(:task_subscription, task: target, user: user)
          end

          it "doesn't create a task_subscription" do
            expect do
              task_connection.subscribe_user
            end.not_to change(TaskSubscription, :count)
          end
        end
      end

      context "and source doesn't have a user" do
        let(:source) { Fabricate.build(:task, project: project) }

        let(:task_connection) do
          Fabricate.build(:task_connection, source: source, target: target)
        end

        it "doesn't create a task_subscription" do
          expect do
            task_connection.subscribe_user
          end.not_to change(TaskSubscription, :count)
        end
      end
    end

    context "when no target task" do
      let(:task_connection) do
        Fabricate.build(:task_connection, source: source, target: nil)
      end

      it "doesn't create a task_subscription for the task user" do
        expect do
          task_connection.subscribe_user
        end.not_to change(TaskSubscription, :count)
      end
    end

    context "when no source task" do
      let(:task_connection) do
        Fabricate.build(:task_connection, source: nil, target: target)
      end

      it "doesn't create a task_subscription for the task user" do
        expect do
          task_connection.subscribe_user
        end.not_to change(TaskSubscription, :count)
      end
    end
  end
end
