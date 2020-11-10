# frozen_string_literal: true

require "rails_helper"

RSpec.describe IssueReopening, type: :model do
  let(:issue) { Fabricate(:issue) }
  let(:user) { Fabricate(:user_reviewer) }

  before do
    @issue_reopening = IssueReopening.new(issue_id: issue.id, user_id: user.id)
  end

  subject { @issue_reopening }

  it { is_expected.to respond_to(:issue_id) }
  it { is_expected.to respond_to(:user_id) }

  it { is_expected.to be_valid }

  it { is_expected.to validate_presence_of(:issue_id) }
  it { is_expected.to validate_presence_of(:user_id) }

  it { is_expected.to belong_to(:issue) }
  it { is_expected.to respond_to(:user) }

  describe "#subscribe_user" do
    let(:user) { Fabricate(:user_reviewer) }

    context "when issue" do
      let(:issue) { Fabricate(:issue) }

      context "and user" do
        let(:issue_reopening) do
          Fabricate(:issue_reopening, issue: issue, user: user)
        end

        context "that is not subscribed" do
          it "creates a new IssueSubscription for the user" do
            expect do
              issue_reopening.subscribe_user
            end.to change(user.issue_subscriptions, :count).by(1)
          end
        end

        context "that is already subscribed" do
          before { Fabricate(:issue_subscription, issue: issue, user: user) }

          it "doesn't create a IssueSubscription" do
            expect do
              issue_reopening.subscribe_user
            end.not_to change(IssueSubscription, :count)
          end
        end
      end

      context "and no user" do
        let(:issue) { Fabricate(:issue) }

        let(:issue_reopening) do
          Fabricate.build(:issue_reopening, user: nil)
        end

        it "doesn't create a issue_subscription" do
          expect do
            issue_reopening.subscribe_user
          end.not_to change(IssueSubscription, :count)
        end
      end
    end

    context "when no issue" do
      let(:issue_reopening) do
        Fabricate.build(:issue_reopening, issue: nil)
      end

      it "doesn't create a IssueSubscription" do
        expect do
          issue_reopening.subscribe_user
        end.not_to change(IssueSubscription, :count)
      end
    end
  end
end
