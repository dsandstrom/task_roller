# frozen_string_literal: true

require "rails_helper"

RSpec.describe Worker, type: :model do
  before { @worker = Worker.new }

  subject { @worker }

  it { is_expected.to be_a(Employee) }
end
