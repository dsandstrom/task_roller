# frozen_string_literal: true

require "rails_helper"

RSpec.describe TaskNotification, type: :model do
  let(:task) { Fabricate(:task) }
  let(:user) { Fabricate(:user_reporter) }

  before do
    @task_notification = TaskNotification.new(task_id: task.id,
                                              user_id: user.id, event: "new")
  end

  subject { @task_notification }

  it { is_expected.to be_valid }

  it { is_expected.to respond_to(:task_id) }
  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:task_comment_id) }
  it { is_expected.to respond_to(:event) }
  it { is_expected.to respond_to(:details) }

  it { is_expected.to validate_presence_of(:task_id) }
  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_length_of(:details).is_at_most(100) }

  describe "#event" do
    context "when a valid value" do
      %w[new comment status].each do |value|
        before { subject.event = value }

        it { is_expected.to be_valid }
      end
    end

    context "when an invalid value" do
      ["notnew", nil, ""].each do |value|
        before { subject.event = value }

        it { is_expected.not_to be_valid }
      end
    end
  end

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:task) }
  it { is_expected.to belong_to(:task_comment) }

  describe "#send_email" do
    context "for a status change" do
      context "when details is blank" do
        let(:task_notification) do
          Fabricate(:task_status_notification, task: task, user: user,
                                               details: nil)
        end

        it "doesn't enqueue email" do
          expect do
            task_notification.send_email
          end.not_to have_enqueued_job
        end
      end

      context "when details is 'old,new'" do
        let(:task_notification) do
          Fabricate(:task_status_notification, task: task, user: user,
                                               details: "old,new")
        end

        it "enqueues email" do
          expect do
            task_notification.send_email
          end.to have_enqueued_job.on_queue("mailers").with(
            "TaskMailer", "status", "deliver_now",
            args: [], params: { task: task, user: user, old_status: "old",
                                new_status: "new" }
          )
        end
      end
    end

    context "for a new task" do
      let(:task_notification) do
        Fabricate(:task_new_notification, task: task, user: user)
      end

      it "enqueues email" do
        expect do
          task_notification.send_email
        end.to have_enqueued_job.on_queue("mailers").with(
          "TaskMailer", "new", "deliver_now",
          args: [], params: { task: task, user: user }
        )
      end
    end

    context "for a new comment" do
      let(:comment) { Fabricate(:task_comment, task: task) }

      let(:task_notification) do
        Fabricate(:task_comment_notification, task: task, user: user,
                                              task_comment: comment)
      end

      it "enqueues email" do
        expect do
          task_notification.send_email
        end.to have_enqueued_job.on_queue("mailers").with(
          "TaskMailer", "comment", "deliver_now",
          args: [], params: { task: task, user: user, comment: comment }
        )
      end
    end

    context "for an invalid event" do
      let(:task_notification) do
        Fabricate(:task_notification, task: task, user: user)
      end

      before { task_notification.update_column :event, "invalid" }

      it "doesn't enqueue email" do
        expect do
          task_notification.send_email
        end.not_to have_enqueued_job
      end
    end

    context "for an invalid comment" do
      let(:task_notification) do
        Fabricate(:task_comment_notification, task: task, user: user,
                                              task_comment: nil)
      end

      it "doesn't enqueue email" do
        expect do
          task_notification.send_email
        end.not_to have_enqueued_job
      end
    end
  end
end
