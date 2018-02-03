# frozen_string_literal: true

require "rails_helper"

RSpec.describe IconFileReader, type: :model do
  let(:icon_options) do
    %w[backspace buffer bug bulb calendar cart earth fireball flask fork-repo
       gear globe help image money network notifications options paintbucket
       plane pull-request ribbon scissors settings share speakerphone stopwatch
       textsms trophy umbrella]
  end

  before { @icon_file_reader = IconFileReader.new }

  subject { @icon_file_reader }

  it { expect(subject.options).to eq(icon_options) }
end
