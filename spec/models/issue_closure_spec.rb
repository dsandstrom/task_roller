# frozen_string_literal: true

require "rails_helper"

RSpec.describe IssueClosure, type: :model do
  let(:issue) { Fabricate(:issue) }
  let(:user) { Fabricate(:user_reviewer) }

  before do
    @issue_closure = IssueClosure.new(issue_id: issue.id, user_id: user.id)
  end

  subject { @issue_closure }

  it { is_expected.to respond_to(:issue_id) }
  it { is_expected.to respond_to(:user_id) }

  it { is_expected.to be_valid }

  it { is_expected.to validate_presence_of(:issue_id) }
  it { is_expected.to validate_presence_of(:user_id) }

  it { is_expected.to belong_to(:issue) }
  it { is_expected.to respond_to(:user) }
end
