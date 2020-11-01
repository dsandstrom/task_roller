# frozen_string_literal: true

require "rails_helper"

RSpec.describe Category, type: :model do
  before { @category = Category.new(name: "Category Name") }

  subject { @category }

  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:visible) }
  it { is_expected.to respond_to(:internal) }

  it { is_expected.to have_many(:projects).dependent(:destroy) }
  it { is_expected.to have_many(:issues).through(:projects) }
  it { is_expected.to have_many(:tasks).through(:projects) }
  it do
    is_expected.to have_many(:category_issue_subscriptions).dependent(:destroy)
  end
  it do
    is_expected.to have_many(:category_task_subscriptions).dependent(:destroy)
  end

  it { is_expected.to be_valid }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_length_of(:name).is_at_most(200) }
end
