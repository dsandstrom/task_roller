# frozen_string_literal: true

require "rails_helper"

RSpec.describe IssueConnection, type: :model do
  let(:source) { Fabricate(:issue) }
  let(:target) { Fabricate(:issue) }

  before do
    @issue_connection =
      IssueConnection.new(source_id: source.id, target_id: target.id)
  end

  subject { @issue_connection }

  it { is_expected.to be_valid }
  it { expect(subject.type).to eq("IssueConnection") }

  it { is_expected.to belong_to(:source) }
  it { is_expected.to belong_to(:target) }
end
