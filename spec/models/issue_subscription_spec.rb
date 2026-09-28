require "rails_helper"

RSpec.describe IssueSubscription, type: :model do
  let(:issue) { Fabricate(:issue) }
  let(:user) { Fabricate(:user_reporter) }

  before do
    @issue_subscription = IssueSubscription.new(user_id: user.id,
                                                issue_id: issue.id)
  end

  subject { @issue_subscription }

  it { is_expected.to be_valid }

  context "when a duplicate" do
    it "shouldn't be valid" do
      subject.dup.save
      expect(subject).not_to be_valid
    end
  end

  it { is_expected.to belong_to(:user).required }
  it { is_expected.to belong_to(:issue).required }

  describe "#toggle" do
    context "for an active IssueSubscription" do
      let(:issue_subscription) { Fabricate(:issue_subscription) }

      it "changes active to false" do
        expect do
          issue_subscription.toggle
          issue_subscription.reload
        end.to change(issue_subscription, :active).to(false)
      end
    end

    context "for an inactive IssueSubscription" do
      let(:issue_subscription) { Fabricate(:inactive_issue_subscription) }

      it "changes active to true" do
        expect do
          issue_subscription.toggle
          issue_subscription.reload
        end.to change(issue_subscription, :active).to(true)
      end
    end
  end
end
