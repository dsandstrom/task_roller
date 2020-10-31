# frozen_string_literal: true

require "rails_helper"

RSpec.describe IssueComment, type: :model do
  let(:user) { Fabricate(:user_worker) }
  let(:issue) { Fabricate(:issue) }

  before do
    @issue_comment =
      IssueComment.new(roller_id: issue.id, user_id: user.id, body: "Comment")
  end

  subject { @issue_comment }

  it { is_expected.to be_a(RollerComment) }

  it { expect(subject.type).to eq("IssueComment") }

  it { is_expected.to belong_to(:issue) }

  it { is_expected.to be_valid }
  it { is_expected.to validate_presence_of(:roller_id) }

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
end
