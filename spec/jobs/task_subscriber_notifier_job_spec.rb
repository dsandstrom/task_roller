require "rails_helper"

RSpec.describe TaskSubscriberNotifierJob, type: :job do
  let(:task) { Fabricate(:task) }
  let(:subscriber) { Fabricate(:user) }

  subject { described_class }

  describe "#perform" do
    context "for a newly created task" do
      let(:options) { { event: "new" } }

      it "creates a notification" do
        expect do
          subject.perform_now task, subscriber, options
        end.to change(TaskNotification, :count).by(1)
      end

      it "creates notification for the subscriber" do
        subject.perform_now task, subscriber, options

        notification = TaskNotification.last

        expect(notification.event).to eq("new")
        expect(notification.user).to eq(subscriber)
        expect(notification.task).to eq(task)
        expect(notification.task_comment).to eq(nil)
        expect(notification.details).to eq(nil)
      end

      it "sends email to the subscriber" do
        params = { task: task, user: subscriber }

        expect do
          subject.perform_now task, subscriber, options
        end.to(
          have_enqueued_job.with do |mailer, action, time, options|
            expect(mailer).to eq("TaskMailer")
            expect(action).to eq("new")
            expect(time).to eq("deliver_now")
            expect(options).to eq(args: [], params: params)
          end
        )
      end
    end

    context "for an task that received a comment" do
      let!(:comment) { Fabricate(:task_comment, task: task) }
      let(:options) { { event: "comment", task_comment: comment } }

      it "creates a notification" do
        expect do
          subject.perform_now task, subscriber, options
        end.to change(TaskNotification, :count).by(1)
      end

      it "creates notification for the subscriber" do
        subject.perform_now task, subscriber, options

        notification = subscriber.task_notifications.find_by(event: "comment")

        expect(notification.user).to eq(subscriber)
        expect(notification.task).to eq(task)
        expect(notification.task_comment).to eq(comment)
        expect(notification.details).to eq(nil)
      end

      it "sends email to the subscriber" do
        params = { task: task, user: subscriber, comment: comment }

        expect do
          subject.perform_now task, subscriber, options
        end.to(
          have_enqueued_job.with do |mailer, action, time, options|
            expect(mailer).to eq("TaskMailer")
            expect(action).to eq("comment")
            expect(time).to eq("deliver_now")
            expect(options).to eq(args: [], params: params)
          end
        )
      end
    end

    context "for an task with a status change" do
      let(:options) { { event: "status", details: "unassigned,assigned" } }

      before do
        Fabricate(:task_notification, task: task, user: subscriber,
                                      event: "new")
      end

      it "creates a notification" do
        expect do
          subject.perform_now task, subscriber, options
        end.to change(TaskNotification, :count).by(1)
      end

      it "creates notification for the subscriber" do
        subject.perform_now task, subscriber, options

        notification = subscriber.task_notifications.find_by(event: "status")

        expect(notification.user).to eq(subscriber)
        expect(notification.task).to eq(task)
        expect(notification.task_comment).to eq(nil)
        expect(notification.details).to eq("unassigned,assigned")
      end

      it "sends email to the subscriber" do
        params = { task: task, user: subscriber, old_status: "unassigned",
                   new_status: "assigned" }

        expect do
          subject.perform_now task, subscriber, options
        end.to(
          have_enqueued_job.with do |mailer, action, time, options|
            expect(mailer).to eq("TaskMailer")
            expect(action).to eq("status")
            expect(time).to eq("deliver_now")
            expect(options).to eq(args: [], params: params)
          end
        )
      end
    end

    context "for an task with a second status change" do
      let(:options) do
        { event: "status", details: "assigned,in_review" }
      end

      let!(:notification) do
        Fabricate(:task_notification, task: task, user: subscriber,
                                      event: "status",
                                      details: "unassigned,assigned")
      end

      before do
        Fabricate(:task_notification, task: task, user: subscriber,
                                      event: "new")
      end

      it "doesn't create another notification" do
        expect do
          subject.perform_now task, subscriber, options
        end.not_to change(TaskNotification, :count)
      end

      it "updates the current status notification" do
        expect do
          subject.perform_now task, subscriber, options
          notification.reload
        end.to change(notification, :details).to eq("assigned,in_review")
      end

      it "sends email to the subscriber" do
        params = { task: task, user: subscriber,
                   old_status: "assigned",
                   new_status: "in_review" }

        expect do
          subject.perform_now task, subscriber, options
        end.to(
          have_enqueued_job.with do |mailer, action, time, options|
            expect(mailer).to eq("TaskMailer")
            expect(action).to eq("status")
            expect(time).to eq("deliver_now")
            expect(options).to eq(args: [], params: params)
          end
        )
      end
    end

    context "for invalid options" do
      let(:options) { { event: "" } }

      it "doesn't create a notification" do
        expect do
          subject.perform_now task, subscriber, options
        end.not_to change(TaskNotification, :count)
      end
    end
  end
end
