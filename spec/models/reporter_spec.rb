# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reporter, type: :model do
  before { @reporter = Reporter.new }

  subject { @reporter }

  it { is_expected.to be_a(Employee) }
end
