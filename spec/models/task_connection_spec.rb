# frozen_string_literal: true

require "rails_helper"

RSpec.describe TaskConnection, type: :model do
  let(:project) { Fabricate(:project) }
  let(:source) { Fabricate(:task, project: project) }
  let(:target) { Fabricate(:task, project: project) }
  let(:user) { Fabricate(:user_reviewer) }

  before do
    @task_connection =
      TaskConnection.new(source_id: source.id, target_id: target.id,
                         user_id: user.id)
  end

  subject { @task_connection }

  it { is_expected.to respond_to(:source_id) }
  it { is_expected.to respond_to(:target_id) }
  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:scheme) }

  it { is_expected.to be_valid }

  it { is_expected.to validate_presence_of(:source_id) }
  it { is_expected.to validate_presence_of(:target_id) }
  it { is_expected.to validate_presence_of(:user_id) }

  it { is_expected.to belong_to(:source) }
  it { is_expected.to belong_to(:target) }
  it { is_expected.to respond_to(:user) }

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
    let(:project) { Fabricate(:project) }

    context "when source and target tasks" do
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

          it "creates only 1 TaskSubscription" do
            expect do
              task_connection.subscribe_user
            end.to change(TaskSubscription, :count).by(1)
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

  describe "#validate" do
    describe "#target_has_options" do
      context "when source's project has other tasks" do
        it { expect(subject).to be_valid }
      end

      context "when source's project has no other tasks" do
        before { allow(subject).to receive(:target_options) { nil } }

        it { expect(subject).not_to be_valid }
      end
    end

    describe "#matching_projects" do
      context "when source and target have the same project" do
        it { expect(subject).to be_valid }
      end

      context "when source and target don't have the same project" do
        before { subject.target.project = Fabricate(:project) }

        it { expect(subject).not_to be_valid }
      end

      context "when source and target don't projects" do
        before do
          subject.source.project = nil
          subject.target.project = nil
        end

        it { expect(subject).not_to be_valid }
      end

      context "when source blank" do
        before { subject.source = nil }

        it { expect(subject).not_to be_valid }
      end

      context "when target blank" do
        before { subject.target = nil }

        it { expect(subject).not_to be_valid }
      end
    end
  end
end
