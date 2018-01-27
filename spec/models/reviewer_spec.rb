# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reviewer, type: :model do
  before { @reviewer = Reviewer.new }

  subject { @reviewer }

  it { is_expected.to be_a(Employee) }
  it { is_expected.to be_valid }
end
