# frozen_string_literal: true

require "rails_helper"

RSpec.describe CategoryTaskSubscription, type: :model do
  let(:category) { Fabricate(:category) }
  let(:user) { Fabricate(:user_reporter) }

  before do
    @category_task_subscription =
      CategoryTaskSubscription.new(user_id: user.id, category_id: category.id)
  end

  subject { @category_task_subscription }

  it { is_expected.to be_valid }

  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_presence_of(:category_id) }
  it { is_expected.to validate_presence_of(:type) }

  context "when a duplicate" do
    it "shouldn't be valid" do
      subject.dup.save
      expect(subject).not_to be_valid
    end
  end

  context "when similar, but different type" do
    it "should be valid" do
      subject.dup.save
      subject.type = "Foo"
      expect(subject).to be_valid
    end
  end

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:category) }
end
