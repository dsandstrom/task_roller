require "rails_helper"

RSpec.describe TaskSubscriptionsJob, type: :job do
  include ActiveJob::TestHelper

  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:task) { Fabricate(:task, project: project) }

  subject { described_class }

  describe "#perform" do
    context "when given task" do
      context "without any search subscribers" do
        before do
          Fabricate(:issues_search_subscription, term: nil, category: category)
        end

        it "doesn't generate any TaskSubscriptionJobs" do
          subject.perform_now task

          expect(TaskSubscriptionJob).not_to have_been_enqueued
        end
      end

      context "with a category search subscriber" do
        let(:subscriber) { Fabricate(:user_worker) }

        before do
          Fabricate(:tasks_search_subscription, term: nil, category: category,
                                                user: subscriber)
        end

        it "generates TaskSubscriptionJob for the user" do
          subject.perform_now task

          expect(TaskSubscriptionJob).to have_been_enqueued.exactly(:once)
          expect(TaskSubscriptionJob)
            .to have_been_enqueued.with(task, subscriber, {})
        end
      end

      context "with a project search subscriber" do
        let(:subscriber) { Fabricate(:user_worker) }

        before do
          Fabricate(:tasks_search_subscription, term: nil, project: project,
                                                user: subscriber)
        end

        it "generates TaskSubscriptionJob for the user" do
          subject.perform_now task

          expect(TaskSubscriptionJob).to have_been_enqueued.exactly(:once)
          expect(TaskSubscriptionJob)
            .to have_been_enqueued.with(task, subscriber, {})
        end
      end

      context "with a category and project search subscriber" do
        let(:subscriber) { Fabricate(:user_worker) }

        before do
          Fabricate(:tasks_search_subscription, term: nil, category: category,
                                                user: subscriber)
          Fabricate(:tasks_search_subscription, term: nil, project: project,
                                                user: subscriber)
        end

        it "generates TaskSubscriptionJob for the user" do
          subject.perform_now task

          expect(TaskSubscriptionJob).to have_been_enqueued.exactly(:once)
          expect(TaskSubscriptionJob)
            .to have_been_enqueued.with(task, subscriber, {})
        end
      end

      context "with a search subscriber that is already subscribed" do
        let(:subscriber) { Fabricate(:user_worker) }

        before do
          Fabricate(:inactive_task_subscription, task: task,
                                                 user: subscriber)
          Fabricate(:tasks_search_subscription, term: nil, category: category,
                                                user: subscriber)
        end

        it "generates IssueSubscriptionJob for the user" do
          subject.perform_now task

          expect(TaskSubscriptionJob).not_to have_been_enqueued
        end
      end

      context "with a subscription for the task's user" do
        let(:subscriber) { Fabricate(:user_worker) }

        before do
          Fabricate(:tasks_search_subscription, term: nil, project: project,
                                                user: task.user)
        end

        it "skips the user" do
          subject.perform_now task

          expect(TaskSubscriptionJob).not_to have_been_enqueued
        end
      end

      context "when given options" do
        let(:subscriber) { Fabricate(:user_worker) }

        before do
          Fabricate(:tasks_search_subscription, term: nil, project: project,
                                                user: subscriber)
        end

        it "forwards the options to TaskSubscriptionJob" do
          subject.perform_now task, send_new: true

          expect(TaskSubscriptionJob).to have_been_enqueued.exactly(:once)
          expect(TaskSubscriptionJob)
            .to have_been_enqueued.with(task, subscriber, { send_new: true })
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
