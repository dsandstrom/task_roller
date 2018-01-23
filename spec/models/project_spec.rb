# frozen_string_literal: true

require "rails_helper"

RSpec.describe Project, type: :model do
  before { @project = Project.new(name: "Project Name") }

  subject { @project }

  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:visible) }
  it { is_expected.to respond_to(:internal) }
  it { is_expected.to respond_to(:category_id) }

  it { is_expected.to belong_to(:category) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_length_of(:name).is_at_most(250) }
  it { is_expected.to validate_presence_of(:category_id) }
end
