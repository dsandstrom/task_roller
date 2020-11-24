# frozen_string_literal: true

require "rails_helper"
require "cancan/matchers"

RSpec.describe Ability do
  describe "Category model" do
    describe "for an admin" do
      let(:admin) { Fabricate(:user_admin) }
      subject(:ability) { Ability.new(admin) }

      context "when visible is true" do
        context "and internal is true" do
          let(:category) { Fabricate(:category, visible: true, internal: true) }

          it { is_expected.to be_able_to(:create, category) }
          it { is_expected.to be_able_to(:read, category) }
          it { is_expected.to be_able_to(:update, category) }
          it { is_expected.to be_able_to(:destroy, category) }
        end

        context "and internal is false" do
          let(:category) do
            Fabricate(:category, visible: true, internal: false)
          end

          it { is_expected.to be_able_to(:create, category) }
          it { is_expected.to be_able_to(:read, category) }
          it { is_expected.to be_able_to(:update, category) }
          it { is_expected.to be_able_to(:destroy, category) }
        end
      end

      context "when visible is false" do
        context "and internal is true" do
          let(:category) do
            Fabricate(:category, visible: false, internal: true)
          end

          it { is_expected.to be_able_to(:create, category) }
          it { is_expected.to be_able_to(:read, category) }
          it { is_expected.to be_able_to(:update, category) }
          it { is_expected.to be_able_to(:destroy, category) }
        end

        context "and internal is false" do
          let(:category) do
            Fabricate(:category, visible: false, internal: false)
          end

          it { is_expected.to be_able_to(:create, category) }
          it { is_expected.to be_able_to(:read, category) }
          it { is_expected.to be_able_to(:update, category) }
          it { is_expected.to be_able_to(:destroy, category) }
        end
      end
    end

    %i[reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        context "when visible is true" do
          context "and internal is true" do
            let(:category) do
              Fabricate(:category, visible: true, internal: true)
            end

            it { is_expected.to be_able_to(:create, category) }
            it { is_expected.to be_able_to(:read, category) }
            it { is_expected.to be_able_to(:update, category) }
            it { is_expected.not_to be_able_to(:destroy, category) }
          end

          context "and internal is false" do
            let(:category) do
              Fabricate(:category, visible: true, internal: false)
            end

            it { is_expected.to be_able_to(:create, category) }
            it { is_expected.to be_able_to(:read, category) }
            it { is_expected.to be_able_to(:update, category) }
            it { is_expected.not_to be_able_to(:destroy, category) }
          end
        end

        context "when visible is false" do
          context "and internal is true" do
            let(:category) do
              Fabricate(:category, visible: false, internal: true)
            end

            it { is_expected.to be_able_to(:create, category) }
            it { is_expected.to be_able_to(:read, category) }
            it { is_expected.to be_able_to(:update, category) }
            it { is_expected.not_to be_able_to(:destroy, category) }
          end

          context "and internal is false" do
            let(:category) do
              Fabricate(:category, visible: false, internal: false)
            end

            it { is_expected.to be_able_to(:create, category) }
            it { is_expected.to be_able_to(:read, category) }
            it { is_expected.to be_able_to(:update, category) }
            it { is_expected.not_to be_able_to(:destroy, category) }
          end
        end
      end
    end

    %i[worker].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        context "when visible is true" do
          context "and internal is true" do
            let(:category) do
              Fabricate(:category, visible: true, internal: true)
            end

            it { is_expected.not_to be_able_to(:create, category) }
            it { is_expected.to be_able_to(:read, category) }
            it { is_expected.not_to be_able_to(:update, category) }
            it { is_expected.not_to be_able_to(:destroy, category) }
          end

          context "and internal is false" do
            let(:category) do
              Fabricate(:category, visible: true, internal: false)
            end

            it { is_expected.not_to be_able_to(:create, category) }
            it { is_expected.to be_able_to(:read, category) }
            it { is_expected.not_to be_able_to(:update, category) }
            it { is_expected.not_to be_able_to(:destroy, category) }
          end
        end

        context "when visible is false" do
          context "and internal is true" do
            let(:category) do
              Fabricate(:category, visible: false, internal: true)
            end

            it { is_expected.not_to be_able_to(:create, category) }
            it { is_expected.not_to be_able_to(:read, category) }
            it { is_expected.not_to be_able_to(:update, category) }
            it { is_expected.not_to be_able_to(:destroy, category) }
          end

          context "and internal is false" do
            let(:category) do
              Fabricate(:category, visible: false, internal: false)
            end

            it { is_expected.not_to be_able_to(:create, category) }
            it { is_expected.not_to be_able_to(:read, category) }
            it { is_expected.not_to be_able_to(:update, category) }
            it { is_expected.not_to be_able_to(:destroy, category) }
          end
        end
      end
    end

    %i[reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        context "when visible is true" do
          let(:category) { Fabricate(:category, visible: true) }

          it { is_expected.not_to be_able_to(:create, category) }
          it { is_expected.to be_able_to(:read, category) }
          it { is_expected.not_to be_able_to(:update, category) }
          it { is_expected.not_to be_able_to(:destroy, category) }
        end

        context "when visible is false" do
          let(:category) { Fabricate(:category, visible: false) }

          it { is_expected.not_to be_able_to(:create, category) }
          it { is_expected.not_to be_able_to(:read, category) }
          it { is_expected.not_to be_able_to(:update, category) }
          it { is_expected.not_to be_able_to(:destroy, category) }
        end

        context "when internal is true" do
          let(:category) { Fabricate(:category, internal: true) }

          it { is_expected.not_to be_able_to(:create, category) }
          it { is_expected.not_to be_able_to(:read, category) }
          it { is_expected.not_to be_able_to(:update, category) }
          it { is_expected.not_to be_able_to(:destroy, category) }
        end

        context "when internal is false" do
          let(:category) { Fabricate(:category, internal: false) }

          it { is_expected.not_to be_able_to(:create, category) }
          it { is_expected.to be_able_to(:read, category) }
          it { is_expected.not_to be_able_to(:update, category) }
          it { is_expected.not_to be_able_to(:destroy, category) }
        end
      end
    end
  end

  describe "CategoryIssuesSubscription model" do
    %i[admin reviewer worker].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        context "for a visible category" do
          let(:category) { Fabricate(:category) }

          context "when subscription belongs to them" do
            let(:subscription) do
              Fabricate(:category_issues_subscription, category: category,
                                                       user: current_user)
            end

            it { is_expected.to be_able_to(:create, subscription) }
            it { is_expected.to be_able_to(:read, subscription) }
            it { is_expected.to be_able_to(:update, subscription) }
            it { is_expected.to be_able_to(:destroy, subscription) }
          end

          context "when subscription doesn't belong to them" do
            let(:subscription) do
              Fabricate(:category_issues_subscription, category: category)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end
        end

        context "for an internal category" do
          let(:category) { Fabricate(:internal_category) }

          context "when subscription belongs to them" do
            let(:subscription) do
              Fabricate(:category_issues_subscription, category: category,
                                                       user: current_user)
            end

            it { is_expected.to be_able_to(:create, subscription) }
            it { is_expected.to be_able_to(:read, subscription) }
            it { is_expected.to be_able_to(:update, subscription) }
            it { is_expected.to be_able_to(:destroy, subscription) }
          end
        end

        context "for an invisible category" do
          let(:category) { Fabricate(:invisible_category) }

          context "when subscription belongs to them" do
            let(:subscription) do
              Fabricate(:category_issues_subscription, category: category,
                                                       user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end
        end
      end
    end

    %i[reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        context "for a visible category" do
          let(:category) { Fabricate(:category) }

          context "when subscription belongs to them" do
            let(:subscription) do
              Fabricate(:category_issues_subscription, category: category,
                                                       user: current_user)
            end

            it { is_expected.to be_able_to(:create, subscription) }
            it { is_expected.to be_able_to(:read, subscription) }
            it { is_expected.to be_able_to(:update, subscription) }
            it { is_expected.to be_able_to(:destroy, subscription) }
          end

          context "when subscription doesn't belong to them" do
            let(:subscription) do
              Fabricate(:category_issues_subscription, category: category)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end
        end

        context "for an internal category" do
          let(:category) { Fabricate(:internal_category) }

          context "when subscription belongs to them" do
            let(:subscription) do
              Fabricate(:category_issues_subscription, category: category,
                                                       user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end
        end

        context "for an invisible category" do
          let(:category) { Fabricate(:invisible_category) }

          context "when subscription belongs to them" do
            let(:subscription) do
              Fabricate(:category_issues_subscription, category: category,
                                                       user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end
        end
      end
    end
  end

  describe "CategoryTasksSubscription model" do
    %i[admin reviewer worker].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        context "for a visible category" do
          let(:category) { Fabricate(:category) }

          context "when subscription belongs to them" do
            let(:subscription) do
              Fabricate(:category_tasks_subscription, category: category,
                                                      user: current_user)
            end

            it { is_expected.to be_able_to(:create, subscription) }
            it { is_expected.to be_able_to(:read, subscription) }
            it { is_expected.to be_able_to(:update, subscription) }
            it { is_expected.to be_able_to(:destroy, subscription) }
          end

          context "when subscription doesn't belong to them" do
            let(:subscription) do
              Fabricate(:category_tasks_subscription, category: category)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end
        end

        context "for an internal category" do
          let(:category) { Fabricate(:internal_category) }

          context "when subscription belongs to them" do
            let(:subscription) do
              Fabricate(:category_tasks_subscription, category: category,
                                                      user: current_user)
            end

            it { is_expected.to be_able_to(:create, subscription) }
            it { is_expected.to be_able_to(:read, subscription) }
            it { is_expected.to be_able_to(:update, subscription) }
            it { is_expected.to be_able_to(:destroy, subscription) }
          end
        end

        context "for an invisible category" do
          let(:category) { Fabricate(:invisible_category) }

          context "when subscription belongs to them" do
            let(:subscription) do
              Fabricate(:category_tasks_subscription, category: category,
                                                      user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end
        end
      end
    end

    %i[reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        context "for a visible category" do
          let(:category) { Fabricate(:category) }

          context "when subscription belongs to them" do
            let(:subscription) do
              Fabricate(:category_tasks_subscription, category: category,
                                                      user: current_user)
            end

            it { is_expected.to be_able_to(:create, subscription) }
            it { is_expected.to be_able_to(:read, subscription) }
            it { is_expected.to be_able_to(:update, subscription) }
            it { is_expected.to be_able_to(:destroy, subscription) }
          end

          context "when subscription doesn't belong to them" do
            let(:subscription) do
              Fabricate(:category_tasks_subscription, category: category)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end
        end

        context "for an internal category" do
          let(:category) { Fabricate(:internal_category) }

          context "when subscription belongs to them" do
            let(:subscription) do
              Fabricate(:category_tasks_subscription, category: category,
                                                      user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end
        end

        context "for an invisible category" do
          let(:category) { Fabricate(:invisible_category) }

          context "when subscription belongs to them" do
            let(:subscription) do
              Fabricate(:category_tasks_subscription, category: category,
                                                      user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end
        end
      end
    end
  end
end
