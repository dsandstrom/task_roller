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

        it "generates IssueSubscriptionJob for the user" do
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

        it "generates IssueSubscriptionJob for the user" do
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

        it "generates IssueSubscriptionJob for the user" do
          subject.perform_now issue

          expect(IssueSubscriptionJob).to have_been_enqueued.exactly(:once)
          expect(IssueSubscriptionJob)
            .to have_been_enqueued.with(issue, subscriber, {})
        end
      end

      context "without any search subscribers" do
        before do
          Fabricate(:tasks_search_subscription, term: nil, category: category)
        end

        it "doesn't generate any IssueSubscriptionJobs" do
          subject.perform_now issue

          expect(IssueSubscriptionJob).not_to have_been_enqueued.exactly(:once)
        end
      end

      context "with a category search subscriber" do
        let(:subscriber) { Fabricate(:user_worker) }

        before do
          Fabricate(:issues_search_subscription, term: nil, category: category,
                                                 user: subscriber)
        end

        it "generates IssueSubscriptionJob for the user" do
          subject.perform_now issue

          expect(IssueSubscriptionJob).to have_been_enqueued.exactly(:once)
          expect(IssueSubscriptionJob)
            .to have_been_enqueued.with(issue, subscriber, {})
        end
      end

      context "with a project search subscriber" do
        let(:subscriber) { Fabricate(:user_worker) }

        before do
          Fabricate(:issues_search_subscription, term: nil, project: project,
                                                 user: subscriber)
        end

        it "generates IssueSubscriptionJob for the user" do
          subject.perform_now issue

          expect(IssueSubscriptionJob).to have_been_enqueued.exactly(:once)
          expect(IssueSubscriptionJob)
            .to have_been_enqueued.with(issue, subscriber, {})
        end
      end

      context "with a category and project search subscriber" do
        let(:subscriber) { Fabricate(:user_worker) }

        before do
          Fabricate(:issues_search_subscription, term: nil, category: category,
                                                 user: subscriber)
          Fabricate(:issues_search_subscription, term: nil, project: project,
                                                 user: subscriber)
        end

        it "generates IssueSubscriptionJob for the user" do
          subject.perform_now issue

          expect(IssueSubscriptionJob).to have_been_enqueued.exactly(:once)
          expect(IssueSubscriptionJob)
            .to have_been_enqueued.with(issue, subscriber, {})
        end
      end

      context "with a search subscriber that is already subscribed" do
        let(:subscriber) { Fabricate(:user_worker) }

        before do
          Fabricate(:inactive_issue_subscription, issue: issue,
                                                  user: subscriber)
          Fabricate(:issues_search_subscription, term: nil, category: category,
                                                 user: subscriber)
        end

        it "generates IssueSubscriptionJob for the user" do
          subject.perform_now issue

          expect(IssueSubscriptionJob).to have_been_enqueued.exactly(:once)
          expect(IssueSubscriptionJob)
            .to have_been_enqueued.with(issue, subscriber, {})
        end
      end

      context "with a subscription for the issue's user" do
        before do
          Fabricate(:project_issues_subscription, project: project,
                                                  user: issue.user)
          Fabricate(:issues_search_subscription, term: nil, category: category,
                                                 user: issue.user)
        end

        it "skips the user" do
          subject.perform_now issue

          expect(IssueSubscriptionJob).not_to have_been_enqueued
        end
      end

      context "when given options" do
        let(:subscriber) { Fabricate(:user_worker) }

        before do
          Fabricate(:issues_search_subscription, term: nil, category: category,
                                                 user: subscriber)
        end

        it "forwards the options to IssueSubscriptionJob" do
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
