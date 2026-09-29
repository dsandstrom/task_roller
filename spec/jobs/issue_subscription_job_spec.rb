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

      it "enqueues IssueNotifierJob for the issue and user" do
        subject.perform_now issue, user

        expect(IssueNotifierJob).to have_been_enqueued.exactly(:once)
        expect(IssueNotifierJob).to have_been_enqueued.with(issue, user, {})
      end

      context "and options" do
        let(:current_user) { Fabricate(:user) }

        let(:options) do
          {  event: "status", details: "pending,being_worked_on" }
        end

        it "forwards them to IssueNotifierJob without current_user" do
          subject.perform_now issue, user,
                              options.merge(current_user: current_user)

          expect(IssueNotifierJob).to have_been_enqueued.exactly(:once)
          expect(IssueNotifierJob)
            .to have_been_enqueued.with(issue, user, options)
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
