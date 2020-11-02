# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProjectSubscription, type: :model do
  let(:project) { Fabricate(:project) }
  let(:user) { Fabricate(:user_reporter) }

  before do
    @project_subscription =
      ProjectSubscription.new(user_id: user.id, project_id: project.id)
  end

  subject { @project_subscription }

  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:project_id) }
  it { is_expected.to respond_to(:type) }
end
