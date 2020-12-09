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
        it { is_expected.to be_able_to(:cancel, random_user) }
        it { is_expected.to be_able_to(:promote, random_user) }
      end

      context "when themselves" do
        it { is_expected.to be_able_to(:create, admin) }
        it { is_expected.to be_able_to(:read, admin) }
        it { is_expected.to be_able_to(:update, admin) }
        it { is_expected.not_to be_able_to(:destroy, admin) }
        it { is_expected.not_to be_able_to(:cancel, admin) }
        it { is_expected.not_to be_able_to(:promote, admin) }
      end

      context "when a non-employee user" do
        it { is_expected.not_to be_able_to(:create, non_employee) }
        it { is_expected.to be_able_to(:read, non_employee) }
        it { is_expected.to be_able_to(:update, non_employee) }
        it { is_expected.to be_able_to(:destroy, non_employee) }
        it { is_expected.to be_able_to(:cancel, non_employee) }
        it { is_expected.to be_able_to(:promote, non_employee) }
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
          it { is_expected.not_to be_able_to(:cancel, random_user) }
          it { is_expected.not_to be_able_to(:promote, random_user) }
        end

        context "when themselves" do
          it { is_expected.not_to be_able_to(:create, current_user) }
          it { is_expected.to be_able_to(:read, current_user) }
          it { is_expected.to be_able_to(:update, current_user) }
          it { is_expected.not_to be_able_to(:destroy, current_user) }
          it { is_expected.to be_able_to(:cancel, current_user) }
          it { is_expected.not_to be_able_to(:promote, current_user) }
        end

        context "when a non-employee user" do
          it { is_expected.not_to be_able_to(:create, non_employee) }
          it { is_expected.not_to be_able_to(:read, non_employee) }
          it { is_expected.not_to be_able_to(:update, non_employee) }
          it { is_expected.not_to be_able_to(:destroy, non_employee) }
          it { is_expected.not_to be_able_to(:promote, non_employee) }
        end

        context "when a new Reporter user" do
          let(:new_reporter) { Fabricate.build(:user_reporter) }

          it { is_expected.not_to be_able_to(:create, new_reporter) }
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
        it { is_expected.not_to be_able_to(:cancel, random_user) }
        it { is_expected.not_to be_able_to(:promote, random_user) }
      end

      context "when themselves" do
        it { is_expected.not_to be_able_to(:create, current_user) }
        it { is_expected.not_to be_able_to(:read, current_user) }
        it { is_expected.not_to be_able_to(:update, current_user) }
        it { is_expected.not_to be_able_to(:destroy, current_user) }
        it { is_expected.not_to be_able_to(:cancel, current_user) }
        it { is_expected.not_to be_able_to(:promote, current_user) }
      end

      context "when another non-employee user" do
        it { is_expected.not_to be_able_to(:create, non_employee) }
        it { is_expected.not_to be_able_to(:read, non_employee) }
        it { is_expected.not_to be_able_to(:update, non_employee) }
        it { is_expected.not_to be_able_to(:destroy, non_employee) }
        it { is_expected.not_to be_able_to(:cancel, non_employee) }
        it { is_expected.not_to be_able_to(:promote, non_employee) }
      end
    end

    context "for a guest" do
      subject(:ability) { Ability.new(nil) }

      context "when allowing devise registration" do
        before { allow(User).to receive(:allow_registration?) { true } }

        context "when new Reporter" do
          let(:new_user) { Fabricate.build(:user_reporter) }

          it { is_expected.to be_able_to(:create, new_user) }
          it { is_expected.not_to be_able_to(:read, new_user) }
          it { is_expected.not_to be_able_to(:update, new_user) }
          it { is_expected.not_to be_able_to(:destroy, new_user) }
          it { is_expected.not_to be_able_to(:cancel, new_user) }
          it { is_expected.not_to be_able_to(:promote, new_user) }
        end

        %i[admin reviewer worker].each do |employee_type|
          context "when new #{employee_type}" do
            let(:new_user) { Fabricate.build("user_#{employee_type}") }

            it { is_expected.not_to be_able_to(:create, new_user) }
            it { is_expected.not_to be_able_to(:read, new_user) }
            it { is_expected.not_to be_able_to(:update, new_user) }
            it { is_expected.not_to be_able_to(:destroy, new_user) }
            it { is_expected.not_to be_able_to(:cancel, new_user) }
            it { is_expected.not_to be_able_to(:promote, new_user) }
          end
        end

        context "when no employee_type" do
          let(:new_user) { Fabricate.build(:user, employee_type: nil) }

          it { is_expected.not_to be_able_to(:create, new_user) }
          it { is_expected.not_to be_able_to(:read, new_user) }
          it { is_expected.not_to be_able_to(:update, new_user) }
          it { is_expected.not_to be_able_to(:destroy, new_user) }
          it { is_expected.not_to be_able_to(:cancel, new_user) }
          it { is_expected.not_to be_able_to(:promote, new_user) }
        end
      end

      context "when not allowing devise registration" do
        before { allow(User).to receive(:allow_registration?) { false } }

        User::VALID_EMPLOYEE_TYPES.each do |employee_type|
          context "when new #{employee_type}" do
            let(:new_user) { Fabricate.build("user_#{employee_type.downcase}") }

            it { is_expected.not_to be_able_to(:create, new_user) }
            it { is_expected.not_to be_able_to(:read, new_user) }
            it { is_expected.not_to be_able_to(:update, new_user) }
            it { is_expected.not_to be_able_to(:destroy, new_user) }
            it { is_expected.not_to be_able_to(:cancel, new_user) }
            it { is_expected.not_to be_able_to(:promote, new_user) }
          end
        end

        context "when no employee_type" do
          let(:new_user) { Fabricate.build(:user, employee_type: nil) }

          it { is_expected.not_to be_able_to(:create, new_user) }
          it { is_expected.not_to be_able_to(:read, new_user) }
          it { is_expected.not_to be_able_to(:update, new_user) }
          it { is_expected.not_to be_able_to(:destroy, new_user) }
          it { is_expected.not_to be_able_to(:cancel, new_user) }
          it { is_expected.not_to be_able_to(:promote, new_user) }
        end
      end
    end
  end
end
