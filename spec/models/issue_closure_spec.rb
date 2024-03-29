# frozen_string_literal: true

require "rails_helper"

RSpec.describe IssueClosure, type: :model do
  let(:issue) { Fabricate(:issue) }
  let(:user) { Fabricate(:user_reviewer) }

  before do
    @issue_closure = IssueClosure.new(issue_id: issue.id, user_id: user.id)
  end

  subject { @issue_closure }

  it { is_expected.to be_valid }

  it { is_expected.to belong_to(:issue).required }
  it { is_expected.to belong_to(:user).required }

  describe "#subscribe_user" do
    let(:user) { Fabricate(:user_reviewer) }

    context "when issue" do
      let(:issue) { Fabricate(:issue) }

      context "and user" do
        let(:issue_closure) do
          Fabricate(:issue_closure, issue: issue, user: user)
        end

        context "that is not subscribed" do
          it "creates a new IssueSubscription for the user" do
            expect do
              issue_closure.subscribe_user
            end.to change(user.issue_subscriptions, :count).by(1)
          end
        end

        context "that is already subscribed" do
          before { Fabricate(:issue_subscription, issue: issue, user: user) }

          it "doesn't create a IssueSubscription" do
            expect do
              issue_closure.subscribe_user
            end.not_to change(IssueSubscription, :count)
          end
        end
      end

      context "and no user" do
        let(:issue) { Fabricate(:issue) }

        let(:issue_closure) do
          Fabricate.build(:issue_closure, user: nil)
        end

        it "doesn't create a issue_subscription" do
          expect do
            issue_closure.subscribe_user
          end.not_to change(IssueSubscription, :count)
        end
      end
    end

    context "when no issue" do
      let(:issue_closure) do
        Fabricate.build(:issue_closure, issue: nil)
      end

      it "doesn't create a IssueSubscription" do
        expect do
          issue_closure.subscribe_user
        end.not_to change(IssueSubscription, :count)
      end
    end
  end
end
