# frozen_string_literal: true

require "rails_helper"

RSpec.describe RollerType, type: :model do
  before do
    @roller_type = RollerType.new(name: "Roller Type Name", icon: "icon",
                                  color: "color", type: "IssueType")
  end

  subject { @roller_type }

  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:icon) }
  it { is_expected.to respond_to(:color) }
  it { is_expected.to respond_to(:type) }

  it { is_expected.to be_valid }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_length_of(:name).is_at_most(100) }
  it { is_expected.to validate_uniqueness_of(:name).scoped_to(:type) }
  it { is_expected.to validate_presence_of(:icon) }
  it { is_expected.to validate_presence_of(:color) }
  it { is_expected.to validate_presence_of(:type) }
end
