require "rails_helper"

RSpec.describe IssueNotificationsRemovalJob, type: :job do
  subject { described_class }

  let(:issue) { Fabricate(:issue) }
  let(:user) { Fabricate(:user) }

  describe "#perform" do
    context "when given an Issue and User" do
      context "with a notification" do
        before do
          Fabricate(:issue_notification, issue: issue, user: user)
        end

        it "destroys it" do
          expect do
            subject.perform_now issue, user
          end.to change(IssueNotification, :count).by(-1)
        end
      end

      context "with multiple notifications" do
        before do
          Fabricate(:issue_notification, issue: issue, user: user)
          Fabricate(:issue_notification, issue: issue, user: user)
        end

        it "destroys them all" do
          expect do
            subject.perform_now issue, user
          end.to change(IssueNotification, :count).by(-2)
        end
      end

      context "without a notification" do
        it "doesn't destroy any" do
          expect do
            subject.perform_now issue, user
          end.not_to change(IssueNotification, :count)
        end

        it "doesn't raise an error" do
          expect do
            subject.perform_now issue, user
          end.not_to raise_error
        end
      end
    end
  end
end
