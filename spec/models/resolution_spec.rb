# frozen_string_literal: true

require "rails_helper"

RSpec.describe Resolution, type: :model do
  let(:worker) { Fabricate(:user_worker) }
  let(:issue) { Fabricate(:issue) }

  before do
    @issue = Resolution.new(issue_id: issue.id, user_id: worker.id)
  end

  subject { @issue }

  it { is_expected.to respond_to(:issue_id) }
  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:approved) }
end
