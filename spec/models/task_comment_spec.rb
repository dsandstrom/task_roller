# frozen_string_literal: true

require "rails_helper"

RSpec.describe TaskComment, type: :model do
  let(:user) { Fabricate(:user_worker) }
  let(:task) { Fabricate(:task) }

  before do
    @task_comment =
      TaskComment.new(task_id: task.id, user_id: user.id, body: "Comment")
  end

  subject { @task_comment }

  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:task_id) }
  it { is_expected.to respond_to(:body) }

  it { is_expected.to be_valid }
  it { is_expected.to validate_presence_of(:task_id) }
  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_presence_of(:body) }

  it { is_expected.to belong_to(:task) }
  it { is_expected.to belong_to(:user) }

  describe "#default_scope" do
    it "orders by created_at asc" do
      second_comment = Fabricate(:task_comment)
      first_comment = Fabricate(:task_comment, created_at: 1.day.ago)

      expect(TaskComment.all).to eq([first_comment, second_comment])
    end
  end

  describe "#body_html" do
    context "when body is **foo**" do
      before { subject.body = "**foo**" }

      it "adds strong tags" do
        expect(subject.body_html).to eq("<p><strong>foo</strong></p>\n")
      end
    end

    context "when body is nil" do
      before { subject.body = nil }

      it "returns empty string" do
        expect(subject.body_html).to eq("")
      end
    end

    context "when body is blank" do
      before { subject.body = "" }

      it "returns empty string" do
        expect(subject.body_html).to eq("")
      end
    end
  end

  describe "#subscribe_user" do
    let(:user) { Fabricate(:user_reviewer) }
    let(:subscriber) { Fabricate(:user_reporter) }

    context "when task" do
      context "and task_comment has a user" do
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

    context "when no task" do
      let(:task_comment) do
        Fabricate.build(:task_comment, task: nil, user: user)
      end

      it "doesn't create a task_subscription for the task user" do
        expect do
          task_comment.subscribe_user
        end.not_to change(TaskSubscription, :count)
      end
    end
  end
end
