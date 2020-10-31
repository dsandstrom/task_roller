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

  describe "#subscribe_user", focus: true do
    let(:user) { Fabricate(:user_reviewer) }
    let(:subscriber) { Fabricate(:user_reporter) }

    context "when task" do
      context "and not provided a subscriber" do
        context "but task_comment has a user" do
          let(:task_comment) do
            Fabricate(:task_comment, task: task, user: user)
          end

          context "that is not subscribed" do
            it "creates a task_subscription for the task user" do
              expect do
                task_comment.subscribe_user
              end.to change(user.task_subscriptions, :count).by(1)
            end
          end

          context "that is already subscribed" do
            before do
              Fabricate(:task_subscription, task: task, user: user)
            end

            it "doesn't create a task_subscription" do
              expect do
                task_comment.subscribe_user
              end.not_to change(TaskSubscription, :count)
            end
          end
        end

        context "and task_comment doesn't have a user" do
          let(:task_comment) do
            Fabricate.build(:task_comment, task: task, user: nil)
          end

          it "doesn't create a task_subscription" do
            expect do
              task_comment.subscribe_user
            end.not_to change(TaskSubscription, :count)
          end
        end
      end

      context "and provided a subscriber" do
        let(:task_comment) { Fabricate(:task_comment, task: task, user: user) }

        context "that is not subscribed" do
          it "creates a task_subscription for the subscriber" do
            expect do
              task_comment.subscribe_user(subscriber)
            end.to change(subscriber.task_subscriptions, :count).by(1)
          end

          it "doesn't create a task_subscription for the task user" do
            expect do
              task_comment.subscribe_user(subscriber)
            end.to change(TaskSubscription, :count).by(1)
          end
        end
      end
    end

    context "when no task" do
      let(:task_comment) do
        Fabricate.build(:task_comment, task: nil, user: user)
      end

      it "doesn't create a task_subscription for the task user" do
        expect do
          task_comment.subscribe_user(subscriber)
        end.not_to change(TaskSubscription, :count)
      end
    end
  end
end
