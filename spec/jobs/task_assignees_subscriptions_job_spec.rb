require "rails_helper"

RSpec.describe TaskAssigneesSubscriptionsJob, type: :job do
  include ActiveJob::TestHelper

  subject { described_class }

  describe "#perform" do
    context "when given task" do
      context "without any assignees" do
        let(:task) { Fabricate(:task, assignees: []) }

        it "doesn't generate any TaskSubscriptionJobs" do
          subject.perform_now task

          expect(TaskSubscriptionJob).not_to have_been_enqueued
        end
      end

      context "with an assignee" do
        let(:assignee) { Fabricate(:user_worker) }
        let(:task) { Fabricate(:task, assignees: [assignee]) }

        it "generates a TaskSubscriptionJob for the assignee" do
          subject.perform_now task

          expect(TaskSubscriptionJob).to have_been_enqueued.exactly(:once)
          expect(TaskSubscriptionJob)
            .to have_been_enqueued.with(task, assignee)
        end
      end
    end

    context "when not given task" do
      it "doesn't generate any TaskSubscriptionJobs" do
        subject.perform_now nil

        expect(TaskSubscriptionJob).not_to have_been_enqueued
      end
    end
  end
end
