# frozen_string_literal: true

require "rails_helper"

RSpec.describe RollerComment, type: :model do
  let(:user) { Fabricate(:user_worker) }

  before do
    @roller_comment = RollerComment.new(user_id: user.id, body: "Comment")
  end

  subject { @roller_comment }

  it { is_expected.to respond_to(:type) }
  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:roller_id) }
  it { is_expected.to respond_to(:body) }

  it { is_expected.to belong_to(:user) }

  it { is_expected.to be_valid }
  it { is_expected.to validate_presence_of(:body) }
  it { is_expected.to validate_presence_of(:user_id) }
end
