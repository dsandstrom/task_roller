# frozen_string_literal: true

require "rails_helper"

RSpec.describe Category, type: :model do
  before { @category = Category.new(name: "Category Name") }

  subject { @category }

  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:visible) }
  it { is_expected.to respond_to(:internal) }

  it { is_expected.to have_many(:projects) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_length_of(:name).is_at_most(200) }
end
