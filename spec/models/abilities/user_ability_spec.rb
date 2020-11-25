# frozen_string_literal: true

require "rails_helper"
require "cancan/matchers"

RSpec.describe Ability do
  describe "User model" do
    let(:random_user) { Fabricate(:user_reviewer) }
    let(:non_employee) { Fabricate(:user_unemployed) }

    describe "for an admin" do
      let(:admin) { Fabricate(:user_admin) }
      subject(:ability) { Ability.new(admin) }

      context "when another user" do
        it { is_expected.to be_able_to(:create, random_user) }
        it { is_expected.to be_able_to(:read, random_user) }
        it { is_expected.to be_able_to(:update, random_user) }
        it { is_expected.to be_able_to(:destroy, random_user) }
      end

      context "when themselves" do
        it { is_expected.to be_able_to(:create, admin) }
        it { is_expected.to be_able_to(:read, admin) }
        it { is_expected.to be_able_to(:update, admin) }
        it { is_expected.not_to be_able_to(:destroy, admin) }
      end

      context "when a non-employee user" do
        it { is_expected.not_to be_able_to(:create, non_employee) }
        it { is_expected.to be_able_to(:read, non_employee) }
        it { is_expected.to be_able_to(:update, non_employee) }
        it { is_expected.to be_able_to(:destroy, non_employee) }
      end
    end

    %i[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        context "when another user" do
          it { is_expected.not_to be_able_to(:create, random_user) }
          it { is_expected.to be_able_to(:read, random_user) }
          it { is_expected.not_to be_able_to(:update, random_user) }
          it { is_expected.not_to be_able_to(:destroy, random_user) }
        end

        context "when themselves" do
          it { is_expected.not_to be_able_to(:create, current_user) }
          it { is_expected.to be_able_to(:read, current_user) }
          it { is_expected.to be_able_to(:update, current_user) }
          it { is_expected.not_to be_able_to(:destroy, current_user) }
        end

        context "when a non-employee user" do
          it { is_expected.not_to be_able_to(:create, non_employee) }
          it { is_expected.not_to be_able_to(:read, non_employee) }
          it { is_expected.not_to be_able_to(:update, non_employee) }
          it { is_expected.not_to be_able_to(:destroy, non_employee) }
        end
      end
    end

    context "for a non-employee" do
      let(:current_user) { Fabricate(:user_unemployed) }
      subject(:ability) { Ability.new(current_user) }

      context "when another user" do
        it { is_expected.not_to be_able_to(:create, random_user) }
        it { is_expected.not_to be_able_to(:read, random_user) }
        it { is_expected.not_to be_able_to(:update, random_user) }
        it { is_expected.not_to be_able_to(:destroy, random_user) }
      end

      context "when themselves" do
        it { is_expected.not_to be_able_to(:create, current_user) }
        it { is_expected.not_to be_able_to(:read, current_user) }
        it { is_expected.not_to be_able_to(:update, current_user) }
        it { is_expected.not_to be_able_to(:destroy, current_user) }
      end

      context "when another non-employee user" do
        it { is_expected.not_to be_able_to(:create, non_employee) }
        it { is_expected.not_to be_able_to(:read, non_employee) }
        it { is_expected.not_to be_able_to(:update, non_employee) }
        it { is_expected.not_to be_able_to(:destroy, non_employee) }
      end
    end
  end
end