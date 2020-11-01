# frozen_string_literal: true

require "rails_helper"

RSpec.describe CategorySubscription, type: :model do
  let(:category) { Fabricate(:category) }
  let(:user) { Fabricate(:user_reporter) }

  before do
    @category_subscription =
      CategorySubscription.new(user_id: user.id, category_id: category.id)
  end

  subject { @category_subscription }

  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:category_id) }
  it { is_expected.to respond_to(:type) }
end
