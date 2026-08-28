require "rails_helper"

RSpec.describe TaskSubscribersNotifierJob, type: :job do
  include ActiveJob::TestHelper

  let(:task) { Fabricate(:task) }
  let(:current_user) { Fabricate(:user_reviewer) }

  subject { described_class }

  describe "#perform" do
    let(:options) { { event: "status", details: "unassigned,assigned" } }

    context "for an task with subscribers" do
      let(:subscriber) { Fabricate(:user) }

      context "and options has a current_user" do
        let(:bulk_options) { options.merge(current_user: current_user) }

        before do
          Fabricate(:task_subscription, task: task, user: current_user)
          Fabricate(:task_subscription, task: task, user: subscriber)
        end

        it "enqueues one TaskNotifierJob" do
          subject.perform_now task, bulk_options

          expect(TaskNotifierJob)
            .to have_been_enqueued.exactly(:once)
          expect(TaskNotifierJob)
            .to have_been_enqueued.with(task, subscriber, options)
        end
      end

      context "and options doesn't have a current_user" do
        let(:bulk_options) { options }

        before do
          Fabricate(:task_subscription, task: task, user: current_user)
          Fabricate(:task_subscription, task: task, user: subscriber)
        end

        it "enqueues one TaskNotifierJob" do
          subject.perform_now task, bulk_options

          expect(TaskNotifierJob)
            .to have_been_enqueued.exactly(:twice)
          expect(TaskNotifierJob)
            .to have_been_enqueued.with(task, subscriber, options)
          expect(TaskNotifierJob)
            .to have_been_enqueued.with(task, current_user, options)
        end
      end
    end

    context "for an task without subscribers" do
      it "doesn't enqueue a TaskNotifierJob" do
        subject.perform_now task, options

        expect(TaskNotifierJob).not_to have_been_enqueued
      end
    end
  end
end
