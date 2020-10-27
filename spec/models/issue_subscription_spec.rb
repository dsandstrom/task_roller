# frozen_string_literal: true

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

  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_presence_of(:issue_id) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:issue) }
end
