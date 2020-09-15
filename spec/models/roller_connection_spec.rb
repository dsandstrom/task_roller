# frozen_string_literal: true

require "rails_helper"

RSpec.describe RollerConnection, type: :model do
  let(:source) { Fabricate(:issue) }
  let(:target) { Fabricate(:issue) }

  before do
    @roller_connection =
      RollerConnection.new(source_id: source.id, target_id: target.id)
  end

  subject { @roller_connection }

  it { is_expected.to respond_to(:type) }
  it { is_expected.to respond_to(:source_id) }
  it { is_expected.to respond_to(:target_id) }
  it { is_expected.to respond_to(:scheme) }

  it { is_expected.to be_valid }
  it { is_expected.to validate_presence_of(:source_id) }
  it { is_expected.to validate_presence_of(:target_id) }
end
