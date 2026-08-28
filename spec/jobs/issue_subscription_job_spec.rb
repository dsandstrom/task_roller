require "rails_helper"

RSpec.describe IssueSubscriptionJob, type: :job do
  include ActiveJob::TestHelper

  let(:issue) { Fabricate(:issue) }
  let(:user) { Fabricate(:user_worker) }

  subject { described_class }

  describe "#perform" do
    context "when given issue and user" do
      it "runs subscribe_user for issue and user" do
        expect(issue).to receive(:subscribe_user).with(user)

        subject.perform_now issue, user
      end

      context "and send_new is default" do
        it "doesn't enqueue any jobs" do
          expect do
            subject.perform_now issue, user
          end.not_to have_enqueued_job
        end
      end

      context "and send_new is false" do
        it "doesn't enqueue any jobs" do
          expect do
            subject.perform_now issue, user, { send_new: false }
          end.not_to have_enqueued_job
        end
      end

      context "and send_new is true" do
        it "enqueues IssueNotifierJob for the issue and user" do
          subject.perform_now issue, user, { send_new: true }

          expect(IssueNotifierJob).to have_been_enqueued.exactly(:once)
          expect(IssueNotifierJob)
            .to have_been_enqueued.with(issue, user, { event: "new" })
        end
      end
    end

    context "when not given issue" do
      it "doesn't raise an error" do
        expect do
          subject.perform_now nil, user
        end.not_to raise_error
      end
    end

    context "when not given user" do
      it "doesn't raise an error" do
        expect do
          subject.perform_now issue, nil
        end.not_to raise_error
      end

      it "doesn't run subscribe_user" do
        expect(issue).not_to receive(:subscribe_user)

        subject.perform_now issue, nil
      end
    end
  end
end
