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

  it { is_expected.to belong_to(:task).required }
  it { is_expected.to belong_to(:user).required }

  describe "#subscribe_user" do
    let(:user) { Fabricate(:user_reviewer) }

    context "when task" do
      let(:task) { Fabricate(:task) }

      context "and user" do
        let(:task_closure) do
          Fabricate(:task_closure, task: task, user: user)
        end

        context "that is not subscribed" do
          it "creates a new TaskSubscription for the user" do
            expect do
              task_closure.subscribe_user
            end.to change(user.task_subscriptions, :count).by(1)
          end
        end

        context "that is already subscribed" do
          before { Fabricate(:task_subscription, task: task, user: user) }

          it "doesn't create a TaskSubscription" do
            expect do
              task_closure.subscribe_user
            end.not_to change(TaskSubscription, :count)
          end
        end
      end

      context "and no user" do
        let(:task) { Fabricate(:task) }

        let(:task_closure) do
          Fabricate.build(:task_closure, user: nil)
        end

        it "doesn't create a task_subscription" do
          expect do
            task_closure.subscribe_user
          end.not_to change(TaskSubscription, :count)
        end
      end
    end

    context "when no task" do
      let(:task_closure) do
        Fabricate.build(:task_closure, task: nil)
      end

      it "doesn't create a TaskSubscription" do
        expect do
          task_closure.subscribe_user
        end.not_to change(TaskSubscription, :count)
      end
    end
  end
end
