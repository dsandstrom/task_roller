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
end
