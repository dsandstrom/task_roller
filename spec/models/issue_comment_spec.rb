# frozen_string_literal: true

require "rails_helper"

RSpec.describe IssueComment, type: :model do
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
    context "when issue has subscribers" do
      let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

      before { issue.subscribers << user }

      it "creates notification" do
        expect do
          issue_comment.notify_subscribers
        end.to change(issue.notifications, :count).by(1)
      end

      it "sends email" do
        expect do
          issue_comment.notify_subscribers
        end.to have_enqueued_job.on_queue("mailers")
      end
    end

    context "when user subscribed to issue" do
      let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

      before { issue.subscribers << issue_comment.user }

      it "doesn't create notification" do
        expect do
          issue_comment.notify_subscribers
        end.not_to change(IssueNotification, :count)
      end

      it "doesn't send email" do
        expect do
          issue_comment.notify_subscribers
        end.not_to have_enqueued_job
      end
    end

    context "when issue doesn't have subscribers" do
      let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

      it "doesn't create notification" do
        expect do
          issue_comment.notify_subscribers
        end.not_to change(IssueNotification, :count)
      end

      it "doesn't send email" do
        expect do
          issue_comment.notify_subscribers
        end.not_to have_enqueued_job
      end
    end

    context "when no issue" do
      let(:issue_comment) { Fabricate(:issue_comment) }

      before do
        issue.subscribers << user
        issue_comment.issue_id = nil
      end

      it "doesn't raise error" do
        expect do
          issue_comment.notify_subscribers
        end.not_to raise_error
      end
    end

    context "when no user" do
      let(:issue_comment) { Fabricate(:issue_comment) }

      before do
        issue.subscribers << user
        issue_comment.user_id = nil
      end

      it "doesn't raise error" do
        expect do
          issue_comment.notify_subscribers
        end.not_to raise_error
      end
    end
  end
end
