# frozen_string_literal: true

require "rails_helper"

RSpec.describe CategoryTasksSubscription, type: :model do
  let(:category) { Fabricate(:category) }
  let(:user) { Fabricate(:user_reporter) }

  before do
    @category_tasks_subscription =
      CategoryTasksSubscription.new(user_id: user.id, category_id: category.id)
  end

  subject { @category_tasks_subscription }

  it { is_expected.to be_valid }

  context "when a duplicate" do
    it "shouldn't be valid" do
      subject.dup.save
      expect(subject).not_to be_valid
    end
  end

  it { is_expected.to belong_to(:user).required }
  it { is_expected.to belong_to(:category).required }
end
