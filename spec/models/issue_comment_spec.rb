require "rails_helper"

RSpec.describe IssueComment, type: :model do
  include ActiveJob::TestHelper

  let(:user) { Fabricate(:user_worker) }
  let(:issue) { Fabricate(:issue) }

  before do
    @issue_comment =
      IssueComment.new(issue_id: issue.id, user_id: user.id, body: "Comment")
  end

  subject { @issue_comment }

  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:issue_id) }
  it { is_expected.to respond_to(:body) }

  it { is_expected.to be_valid }
  it { is_expected.to validate_presence_of(:body) }

  it { is_expected.to belong_to(:issue).required }
  it { is_expected.to belong_to(:user).required }
  it { is_expected.to have_many(:notifications) }

  describe "#default_scope" do
    it "orders by created_at asc" do
      second_comment = Fabricate(:issue_comment)
      first_comment = Fabricate(:issue_comment, created_at: 1.day.ago)

      expect(IssueComment.all).to eq([first_comment, second_comment])
    end
  end

  describe "#body_html" do
    context "when body is **foo**" do
      before { subject.body = "**foo**" }

      it "adds strong tags" do
        expect(subject.body_html).to eq("<p><strong>foo</strong></p>\n")
      end
    end

    context "when body is nil" do
      before { subject.body = nil }

      it "returns empty string" do
        expect(subject.body_html).to eq("")
      end
    end

    context "when body is blank" do
      before { subject.body = "" }

      it "returns empty string" do
        expect(subject.body_html).to eq("")
      end
    end
  end

  describe "#subscribe_user" do
    let(:user) { Fabricate(:user_reviewer) }
    let(:subscriber) { Fabricate(:user_reporter) }

    context "when issue" do
      context "and issue_comment has a user" do
        let(:issue_comment) do
          Fabricate(:issue_comment, issue: issue, user: user)
        end

        context "that is not subscribed" do
          it "creates a issue_subscription for the issue user" do
            expect do
              issue_comment.subscribe_user
            end.to change(user.issue_subscriptions, :count).by(1)
          end
        end

        context "that is already subscribed" do
          before do
            Fabricate(:issue_subscription, issue: issue, user: user)
          end

          it "doesn't create a issue_subscription" do
            expect do
              issue_comment.subscribe_user
            end.not_to change(IssueSubscription, :count)
          end
        end
      end

      context "and issue_comment doesn't have a user" do
        let(:issue_comment) do
          Fabricate.build(:issue_comment, issue: issue, user: nil)
        end

        it "doesn't create a issue_subscription" do
          expect do
            issue_comment.subscribe_user
          end.not_to change(IssueSubscription, :count)
        end
      end
    end

    context "when no issue" do
      let(:issue_comment) do
        Fabricate.build(:issue_comment, issue: nil, user: user)
      end

      it "doesn't create a issue_subscription for the issue user" do
        expect do
          issue_comment.subscribe_user
        end.not_to change(IssueSubscription, :count)
      end
    end
  end

  describe "#notify_subscribers" do
    let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }
    let(:job_options) do
      { event: "comment", issue_comment: issue_comment,
        current_user: issue_comment.user }
    end

    context "when issue has subscribers" do
      before { issue.subscribers << user }

      it "enqueues IssueSubscribersNotifierJob" do
        issue_comment.notify_subscribers

        expect(IssueSubscribersNotifierJob)
          .to have_been_enqueued.exactly(:once)
        expect(IssueSubscribersNotifierJob)
          .to have_been_enqueued.with(issue, job_options)
      end
    end

    context "when user subscribed to issue" do
      it "enqueues IssueSubscribersNotifierJob" do
        issue_comment.notify_subscribers

        expect(IssueSubscribersNotifierJob)
          .to have_been_enqueued.exactly(:once)
        expect(IssueSubscribersNotifierJob)
          .to have_been_enqueued.with(issue, job_options)
      end
    end

    context "when issue doesn't have subscribers" do
      it "enqueues IssueSubscribersNotifierJob" do
        issue_comment.notify_subscribers

        expect(IssueSubscribersNotifierJob)
          .to have_been_enqueued.exactly(:once)
        expect(IssueSubscribersNotifierJob)
          .to have_been_enqueued.with(issue, job_options)
      end
    end

    context "when no issue" do
      before do
        issue.subscribers << user
        issue_comment.issue_id = nil
      end

      it "doesn't raise error" do
        expect do
          issue_comment.notify_subscribers
        end.not_to raise_error
      end

      it "doesn't enqueue IssueSubscribersNotifierJob" do
        issue_comment.notify_subscribers

        expect(IssueSubscribersNotifierJob).not_to have_been_enqueued
      end
    end

    context "when no user" do
      before do
        issue.subscribers << user
        issue_comment.user_id = nil
      end

      it "doesn't raise error" do
        expect do
          issue_comment.notify_subscribers
        end.not_to raise_error
      end

      it "enqueues IssueSubscribersNotifierJob" do
        issue_comment.notify_subscribers

        expect(IssueSubscribersNotifierJob)
          .to have_been_enqueued.exactly(:once)
        expect(IssueSubscribersNotifierJob)
          .to have_been_enqueued.with(issue, job_options)
      end
    end
  end
end
