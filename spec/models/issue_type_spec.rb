# frozen_string_literal: true

require "rails_helper"

RSpec.describe IssueType, type: :model do
  before do
    @issue_type =
      IssueType.new(name: "Issue Type Name", icon: "bug", color: "red")
  end

  subject { @issue_type }

  it { is_expected.to be_a(RollerType) }
  it { expect(subject.type).to eq("IssueType") }
  it { is_expected.to be_valid }
end
