require "rails_helper"

RSpec.describe IssueSubscriberNotifierJob, type: :job do
  let(:issue) { Fabricate(:issue) }
  let(:subscriber) { Fabricate(:user) }

  subject { described_class }

  describe "#perform" do
    context "for a newly created issue" do
      let(:options) { { event: "new" } }

      it "creates a notification" do
        expect do
          subject.perform_now issue, subscriber, options
        end.to change(IssueNotification, :count).by(1)
      end

      it "creates notification for the subscriber" do
        subject.perform_now issue, subscriber, options

        notification = IssueNotification.last

        expect(notification.event).to eq("new")
        expect(notification.user).to eq(subscriber)
        expect(notification.issue).to eq(issue)
        expect(notification.issue_comment).to eq(nil)
        expect(notification.details).to eq(nil)
      end

      it "sends email to the subscriber" do
        params = { issue: issue, user: subscriber }

        expect do
          subject.perform_now issue, subscriber, options
        end.to(
          have_enqueued_job.with do |mailer, action, time, options|
            expect(mailer).to eq("IssueMailer")
            expect(action).to eq("new")
            expect(time).to eq("deliver_now")
            expect(options).to eq(args: [], params: params)
          end
        )
      end
    end

    context "for an issue that received a comment" do
      let!(:comment) { Fabricate(:issue_comment, issue: issue) }
      let(:options) { { event: "comment", issue_comment: comment } }

      it "creates a notification" do
        expect do
          subject.perform_now issue, subscriber, options
        end.to change(IssueNotification, :count).by(1)
      end

      it "creates notification for the subscriber" do
        subject.perform_now issue, subscriber, options

        notification = subscriber.issue_notifications.find_by(event: "comment")

        expect(notification.user).to eq(subscriber)
        expect(notification.issue).to eq(issue)
        expect(notification.issue_comment).to eq(comment)
        expect(notification.details).to eq(nil)
      end

      it "sends email to the subscriber" do
        params = { issue: issue, user: subscriber, comment: comment }

        expect do
          subject.perform_now issue, subscriber, options
        end.to(
          have_enqueued_job.with do |mailer, action, time, options|
            expect(mailer).to eq("IssueMailer")
            expect(action).to eq("comment")
            expect(time).to eq("deliver_now")
            expect(options).to eq(args: [], params: params)
          end
        )
      end
    end

    context "for an issue with a status change" do
      let(:options) { { event: "status", details: "pending,being_worked_on" } }

      before do
        Fabricate(:issue_notification, issue: issue, user: subscriber,
                                       event: "new")
      end

      it "creates a notification" do
        expect do
          subject.perform_now issue, subscriber, options
        end.to change(IssueNotification, :count).by(1)
      end

      it "creates notification for the subscriber" do
        subject.perform_now issue, subscriber, options

        notification = subscriber.issue_notifications.find_by(event: "status")

        expect(notification.user).to eq(subscriber)
        expect(notification.issue).to eq(issue)
        expect(notification.issue_comment).to eq(nil)
        expect(notification.details).to eq("pending,being_worked_on")
      end

      it "sends email to the subscriber" do
        params = { issue: issue, user: subscriber, old_status: "pending",
                   new_status: "being_worked_on" }

        expect do
          subject.perform_now issue, subscriber, options
        end.to(
          have_enqueued_job.with do |mailer, action, time, options|
            expect(mailer).to eq("IssueMailer")
            expect(action).to eq("status")
            expect(time).to eq("deliver_now")
            expect(options).to eq(args: [], params: params)
          end
        )
      end
    end

    context "for an issue with a second status change" do
      let(:options) do
        { event: "status", details: "being_worked_on,addressed" }
      end

      let!(:notification) do
        Fabricate(:issue_notification, issue: issue, user: subscriber,
                                       event: "status",
                                       details: "pending,being_worked_on")
      end

      before do
        Fabricate(:issue_notification, issue: issue, user: subscriber,
                                       event: "new")
      end

      it "doesn't create another notification" do
        expect do
          subject.perform_now issue, subscriber, options
        end.not_to change(IssueNotification, :count)
      end

      it "updates the current status notification" do
        expect do
          subject.perform_now issue, subscriber, options
          notification.reload
        end.to change(notification, :details).to eq("being_worked_on,addressed")
      end

      it "sends email to the subscriber" do
        params = { issue: issue, user: subscriber,
                   old_status: "being_worked_on",
                   new_status: "addressed" }

        expect do
          subject.perform_now issue, subscriber, options
        end.to(
          have_enqueued_job.with do |mailer, action, time, options|
            expect(mailer).to eq("IssueMailer")
            expect(action).to eq("status")
            expect(time).to eq("deliver_now")
            expect(options).to eq(args: [], params: params)
          end
        )
      end
    end
  end
end
