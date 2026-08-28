require "rails_helper"

RSpec.describe TaskSubscriptionsJob, type: :job do
  include ActiveJob::TestHelper

  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:task) { Fabricate(:task, project: project) }

  subject { described_class }

  describe "#perform" do
    context "when given task" do
      context "without any category and project subscribers" do
        before do
          Fabricate(:category_issues_subscription, category: category)
          Fabricate(:project_issues_subscription, project: project)
        end

        it "doesn't generate any TaskSubscriptionJobs" do
          subject.perform_now task

          expect(TaskSubscriptionJob).not_to have_been_enqueued
        end
      end

      context "with a category subscriber" do
        let(:subscriber) { Fabricate(:user_worker) }

        before do
          Fabricate(:category_tasks_subscription, category: category,
                                                  user: subscriber)
        end

        it "generates TaskSubscriptionJob for the task user" do
          subject.perform_now task

          expect(TaskSubscriptionJob).to have_been_enqueued.exactly(:once)
          expect(TaskSubscriptionJob)
            .to have_been_enqueued.with(task, subscriber, {})
        end
      end

      context "with a project subscriber" do
        let(:subscriber) { Fabricate(:user_worker) }

        before do
          Fabricate(:project_tasks_subscription, project: project,
                                                 user: subscriber)
        end

        it "generates TaskSubscriptionJob for the task user" do
          subject.perform_now task

          expect(TaskSubscriptionJob).to have_been_enqueued.exactly(:once)
          expect(TaskSubscriptionJob)
            .to have_been_enqueued.with(task, subscriber, {})
        end
      end

      context "with a category and project subscriber" do
        let(:subscriber) { Fabricate(:user_worker) }

        before do
          Fabricate(:category_tasks_subscription, category: category,
                                                  user: subscriber)
          Fabricate(:project_tasks_subscription, project: project,
                                                 user: subscriber)
        end

        it "generates TaskSubscriptionJob for the task user" do
          subject.perform_now task

          expect(TaskSubscriptionJob).to have_been_enqueued.exactly(:once)
          expect(TaskSubscriptionJob)
            .to have_been_enqueued.with(task, subscriber, {})
        end
      end

      context "with the task.user subscribed to the project" do
        let(:subscriber) { Fabricate(:user_worker) }

        before do
          Fabricate(:project_tasks_subscription, project: project,
                                                 user: task.user)
        end

        it "generates TaskSubscriptionJob for the task user" do
          subject.perform_now task

          expect(TaskSubscriptionJob).to have_been_enqueued.exactly(:once)
          expect(TaskSubscriptionJob)
            .to have_been_enqueued.with(task, task.user, {})
        end
      end

      context "when given options" do
        let(:subscriber) { Fabricate(:user_worker) }

        before do
          Fabricate(:project_tasks_subscription, project: project,
                                                 user: subscriber)
        end

        it "generates IssueSubscriptionJob for the task user" do
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
