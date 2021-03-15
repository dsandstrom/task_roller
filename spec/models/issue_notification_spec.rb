# frozen_string_literal: true

require "rails_helper"

RSpec.describe IssueNotification, type: :model do
  let(:issue) { Fabricate(:issue) }
  let(:user) { Fabricate(:user_reporter) }

  before do
    @issue_notification = IssueNotification.new(issue_id: issue.id,
                                                user_id: user.id, event: "new")
  end

  subject { @issue_notification }

  it { is_expected.to be_valid }

  it { is_expected.to respond_to(:issue_id) }
  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:event) }
  it { is_expected.to respond_to(:details) }

  it { is_expected.to validate_presence_of(:issue_id) }
  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_length_of(:details).is_at_most(100) }

  describe "#event" do
    context "when a valid value" do
      %w[new comment status].each do |value|
        before { subject.event = value }

        it { is_expected.to be_valid }
      end
    end

    context "when an invalid value" do
      ["notnew", nil, ""].each do |value|
        before { subject.event = value }

        it { is_expected.not_to be_valid }
      end
    end
  end

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:issue) }
end
