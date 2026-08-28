require "rails_helper"

RSpec.describe IssueSubscriptionsJob, type: :job do
  include ActiveJob::TestHelper

  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:issue) { Fabricate(:issue, project: project) }

  subject { described_class }

  describe "#perform" do
    context "when given issue" do
      context "without any category and project subscribers" do
        before do
          Fabricate(:category_tasks_subscription, category: category)
          Fabricate(:project_tasks_subscription, project: project)
        end

        it "doesn't generate any IssueSubscriptionJobs" do
          subject.perform_now issue

          expect(IssueSubscriptionJob).not_to have_been_enqueued.exactly(:once)
        end
      end

      context "with a category subscriber" do
        let(:subscriber) { Fabricate(:user_worker) }

        before do
          Fabricate(:category_issues_subscription, category: category,
                                                   user: subscriber)
        end

        it "generates IssueSubscriptionJob for the issue user" do
          subject.perform_now issue

          expect(IssueSubscriptionJob).to have_been_enqueued.exactly(:once)
          expect(IssueSubscriptionJob)
            .to have_been_enqueued.with(issue, subscriber, {})
        end
      end

      context "with a project subscriber" do
        let(:subscriber) { Fabricate(:user_worker) }

        before do
          Fabricate(:project_issues_subscription, project: project,
                                                  user: subscriber)
        end

        it "generates IssueSubscriptionJob for the issue user" do
          subject.perform_now issue

          expect(IssueSubscriptionJob).to have_been_enqueued.exactly(:once)
          expect(IssueSubscriptionJob)
            .to have_been_enqueued.with(issue, subscriber, {})
        end
      end

      context "with a category and project subscriber" do
        let(:subscriber) { Fabricate(:user_worker) }

        before do
          Fabricate(:category_issues_subscription, category: category,
                                                   user: subscriber)
          Fabricate(:project_issues_subscription, project: project,
                                                  user: subscriber)
        end

        it "generates IssueSubscriptionJob for the issue user" do
          subject.perform_now issue

          expect(IssueSubscriptionJob).to have_been_enqueued.exactly(:once)
          expect(IssueSubscriptionJob)
            .to have_been_enqueued.with(issue, subscriber, {})
        end
      end

      context "with the issue.user subscribed to the project" do
        before do
          Fabricate(:project_issues_subscription, project: project,
                                                  user: issue.user)
        end

        it "generates IssueSubscriptionJob for the issue user" do
          subject.perform_now issue

          expect(IssueSubscriptionJob).to have_been_enqueued.exactly(:once)
          expect(IssueSubscriptionJob)
            .to have_been_enqueued.with(issue, issue.user, {})
        end
      end

      context "when given options" do
        let(:subscriber) { Fabricate(:user_worker) }

        before do
          Fabricate(:project_issues_subscription, project: project,
                                                  user: subscriber)
        end

        it "generates IssueSubscriptionJob for the issue user" do
          subject.perform_now issue, send_new: true

          expect(IssueSubscriptionJob).to have_been_enqueued.exactly(:once)
          expect(IssueSubscriptionJob)
            .to have_been_enqueued.with(issue, subscriber, { send_new: true })
        end
      end
    end

    context "when not given issue" do
      it "doesn't generate any IssueSubscriptionJobs" do
        subject.perform_now nil

        expect(IssueSubscriptionJob).not_to have_been_enqueued
      end
    end
  end
end
