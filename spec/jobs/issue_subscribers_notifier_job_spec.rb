require "rails_helper"

RSpec.describe IssueSubscribersNotifierJob, type: :job do
  include ActiveJob::TestHelper

  let(:issue) { Fabricate(:issue) }
  let(:current_user) { Fabricate(:user_reviewer) }

  subject { described_class }

  describe "#perform" do
    let(:options) { { event: "status", details: "unassigned,assigned" } }

    context "for an issue with subscribers" do
      let(:subscriber) { Fabricate(:user) }

      context "and options has a current_user" do
        let(:bulk_options) { options.merge(current_user: current_user) }

        before do
          Fabricate(:issue_subscription, issue: issue, user: current_user)
          Fabricate(:issue_subscription, issue: issue, user: subscriber)
        end

        it "enqueues one IssueSubscriberNotifierJob" do
          subject.perform_now issue, bulk_options

          expect(IssueSubscriberNotifierJob)
            .to have_been_enqueued.exactly(:once)
          expect(IssueSubscriberNotifierJob)
            .to have_been_enqueued.with(issue, subscriber, options)
        end
      end

      context "and options doesn't have a current_user" do
        let(:bulk_options) { options }

        before do
          Fabricate(:issue_subscription, issue: issue, user: current_user)
          Fabricate(:issue_subscription, issue: issue, user: subscriber)
        end

        it "enqueues one IssueSubscriberNotifierJob" do
          subject.perform_now issue, bulk_options

          expect(IssueSubscriberNotifierJob)
            .to have_been_enqueued.exactly(:twice)
          expect(IssueSubscriberNotifierJob)
            .to have_been_enqueued.with(issue, subscriber, options)
          expect(IssueSubscriberNotifierJob)
            .to have_been_enqueued.with(issue, current_user, options)
        end
      end
    end

    context "for an issue without subscribers" do
      it "doesn't enqueue a IssueSubscriberNotifierJob" do
        subject.perform_now issue, options

        expect(IssueSubscriberNotifierJob).not_to have_been_enqueued
      end
    end
  end
end
