# frozen_string_literal: true

require "rails_helper"

RSpec.describe RollerType, type: :model do
  let(:color_options) { %w[green yellow red brown default blue purple] }
  let(:icon_options) do
    { "money" => "57346", "umbrella" => "57347", "trophy" => "57348",
      "speakerphone" => "57349", "buffer" => "57350", "settings" => "57351",
      "scissors" => "57352", "ribbon" => "57353", "pull-request" => "57354",
      "person" => "57355", "person-add" => "57356", "person-group" => "57357",
      "paintbucket" => "57358", "network" => "57359", "bulb" => "57364",
      "cart" => "57365", "calendar" => "57366", "globe" => "57371",
      "options" => "57372", "notifications" => "57373", "plane" => "57374",
      "stopwatch" => "57375", "textsms" => "57376", "bug" => "57382",
      "backspace" => "57384", "earth" => "57388", "flask" => "57389",
      "image" => "57393", "gear" => "57394", "share" => "57395",
      "fireball" => "57362", "fork-repo" => "57363", "help" => "57370" }
  end

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
  it do
    is_expected.to validate_inclusion_of(:icon).in_array(
      icon_options.map(&:first)
    )
  end
  it { is_expected.to validate_presence_of(:color) }
  it { is_expected.to validate_inclusion_of(:color).in_array(color_options) }
  it { is_expected.to validate_presence_of(:type) }
end
