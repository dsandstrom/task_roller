require "rails_helper"
require "cancan/matchers"

RSpec.describe Ability do
  describe "SearchSubscription model" do
    describe "for an admin" do
      let(:admin) { Fabricate(:user_admin) }

      subject(:ability) { Ability.new(admin) }

      context "when belongs to them" do
        let(:search_subscription) do
          Fabricate.build(:search_subscription, user: admin)
        end

        it { is_expected.to be_able_to(:create, search_subscription) }
        it { is_expected.to be_able_to(:read, search_subscription) }
        it { is_expected.to be_able_to(:update, search_subscription) }
        it { is_expected.to be_able_to(:destroy, search_subscription) }
      end

      context "when doesn't belong to them" do
        let(:search_subscription) { Fabricate.build(:search_subscription) }

        it { is_expected.not_to be_able_to(:create, search_subscription) }
        it { is_expected.not_to be_able_to(:read, search_subscription) }
        it { is_expected.not_to be_able_to(:update, search_subscription) }
        it { is_expected.not_to be_able_to(:destroy, search_subscription) }
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      describe "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        subject(:ability) { Ability.new(current_user) }

        context "when belongs to them" do
          let(:search_subscription) do
            Fabricate.build(:search_subscription, user: current_user)
          end

          it { is_expected.to be_able_to(:create, search_subscription) }
          it { is_expected.to be_able_to(:read, search_subscription) }
          it { is_expected.to be_able_to(:update, search_subscription) }
          it { is_expected.to be_able_to(:destroy, search_subscription) }
        end

        context "when doesn't belong to them" do
          let(:search_subscription) { Fabricate.build(:search_subscription) }

          it { is_expected.not_to be_able_to(:create, search_subscription) }
          it { is_expected.not_to be_able_to(:read, search_subscription) }
          it { is_expected.not_to be_able_to(:update, search_subscription) }
          it { is_expected.not_to be_able_to(:destroy, search_subscription) }
        end
      end
    end
  end
end
