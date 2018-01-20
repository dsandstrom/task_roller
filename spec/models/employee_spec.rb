# frozen_string_literal: true

require "rails_helper"

RSpec.describe Employee, type: :model do
  before { @employee = Employee.new }

  subject { @employee }

  it { is_expected.to respond_to(:type) }
end
