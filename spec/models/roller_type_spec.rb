# frozen_string_literal: true

require "rails_helper"

RSpec.describe RollerType, type: :model do
  let(:color_options) { %w[green yellow red brown default blue purple] }
  let(:icon_options) { IconFileReader.new.options }

  before do
    @roller_type = RollerType.new(name: "Roller Type Name", icon: "bulb",
                                  color: "yellow", type: "IssueType")
  end

  subject { @roller_type }

  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:icon) }
  it { is_expected.to respond_to(:color) }
  it { is_expected.to respond_to(:type) }
  it { is_expected.to respond_to(:position) }

  it { is_expected.to be_valid }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_length_of(:name).is_at_most(100) }
  it { is_expected.to validate_uniqueness_of(:name).scoped_to(:type) }
  it { is_expected.to validate_presence_of(:icon) }
  it { is_expected.to validate_inclusion_of(:icon).in_array(icon_options) }
  it { is_expected.to validate_presence_of(:color) }
  it { is_expected.to validate_inclusion_of(:color).in_array(color_options) }
  it { is_expected.to validate_presence_of(:type) }
end
