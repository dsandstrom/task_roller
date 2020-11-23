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

  describe "Issue model" do
    describe "for an admin" do
      let(:category) { Fabricate(:category) }
      let(:project) { Fabricate(:project, category: category) }
      let(:admin) { Fabricate(:user_admin) }

      subject(:ability) { Ability.new(admin) }

      context "when issue category is visible" do
        context "and external" do
          context "while project is visible" do
            context "and external" do
              context "when belongs to them" do
                let(:issue) { Fabricate(:issue, project: project, user: admin) }

                it { is_expected.to be_able_to(:create, issue) }
                it { is_expected.to be_able_to(:read, issue) }
                it { is_expected.to be_able_to(:update, issue) }
                it { is_expected.to be_able_to(:destroy, issue) }
              end

              context "when doesn't belong to them" do
                let(:issue) { Fabricate(:issue, project: project) }

                it { is_expected.not_to be_able_to(:create, issue) }
                it { is_expected.to be_able_to(:read, issue) }
                it { is_expected.to be_able_to(:update, issue) }
                it { is_expected.to be_able_to(:destroy, issue) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:project, category: category, internal: true)
              end

              context "when belongs to them" do
                let(:issue) { Fabricate(:issue, project: project, user: admin) }

                it { is_expected.to be_able_to(:create, issue) }
                it { is_expected.to be_able_to(:read, issue) }
                it { is_expected.to be_able_to(:update, issue) }
                it { is_expected.to be_able_to(:destroy, issue) }
              end

              context "when doesn't belong to them" do
                let(:issue) { Fabricate(:issue, project: project) }

                it { is_expected.not_to be_able_to(:create, issue) }
                it { is_expected.to be_able_to(:read, issue) }
                it { is_expected.to be_able_to(:update, issue) }
                it { is_expected.to be_able_to(:destroy, issue) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:issue) { Fabricate(:issue, project: project, user: admin) }

                it { is_expected.not_to be_able_to(:create, issue) }
                it { is_expected.to be_able_to(:read, issue) }
                it { is_expected.to be_able_to(:update, issue) }
                it { is_expected.to be_able_to(:destroy, issue) }
              end

              context "when doesn't belong to them" do
                let(:issue) { Fabricate(:issue, project: project) }

                it { is_expected.not_to be_able_to(:create, issue) }
                it { is_expected.to be_able_to(:read, issue) }
                it { is_expected.to be_able_to(:update, issue) }
                it { is_expected.to be_able_to(:destroy, issue) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:project, category: category, visible: false,
                                    internal: true)
              end

              context "when belongs to them" do
                let(:issue) { Fabricate(:issue, project: project, user: admin) }

                it { is_expected.not_to be_able_to(:create, issue) }
                it { is_expected.to be_able_to(:read, issue) }
                it { is_expected.to be_able_to(:update, issue) }
                it { is_expected.to be_able_to(:destroy, issue) }
              end

              context "when doesn't belong to them" do
                let(:issue) { Fabricate(:issue, project: project) }

                it { is_expected.not_to be_able_to(:create, issue) }
                it { is_expected.to be_able_to(:read, issue) }
                it { is_expected.to be_able_to(:update, issue) }
                it { is_expected.to be_able_to(:destroy, issue) }
              end
            end
          end
        end
      end

      context "when issue category is invisible" do
        context "and external" do
          let(:category) { Fabricate(:category, visible: false) }

          context "while project is visible" do
            context "and external" do
              context "when belongs to them" do
                let(:issue) { Fabricate(:issue, project: project, user: admin) }

                it { is_expected.not_to be_able_to(:create, issue) }
                it { is_expected.to be_able_to(:read, issue) }
                it { is_expected.to be_able_to(:update, issue) }
                it { is_expected.to be_able_to(:destroy, issue) }
              end

              context "when doesn't belong to them" do
                let(:issue) { Fabricate(:issue, project: project) }

                it { is_expected.not_to be_able_to(:create, issue) }
                it { is_expected.to be_able_to(:read, issue) }
                it { is_expected.to be_able_to(:update, issue) }
                it { is_expected.to be_able_to(:destroy, issue) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:project, category: category, internal: true)
              end

              context "when belongs to them" do
                let(:issue) { Fabricate(:issue, project: project, user: admin) }

                it { is_expected.not_to be_able_to(:create, issue) }
                it { is_expected.to be_able_to(:read, issue) }
                it { is_expected.to be_able_to(:update, issue) }
                it { is_expected.to be_able_to(:destroy, issue) }
              end

              context "when doesn't belong to them" do
                let(:issue) { Fabricate(:issue, project: project) }

                it { is_expected.not_to be_able_to(:create, issue) }
                it { is_expected.to be_able_to(:read, issue) }
                it { is_expected.to be_able_to(:update, issue) }
                it { is_expected.to be_able_to(:destroy, issue) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:issue) { Fabricate(:issue, project: project, user: admin) }

                it { is_expected.not_to be_able_to(:create, issue) }
                it { is_expected.to be_able_to(:read, issue) }
                it { is_expected.to be_able_to(:update, issue) }
                it { is_expected.to be_able_to(:destroy, issue) }
              end

              context "when doesn't belong to them" do
                let(:issue) { Fabricate(:issue, project: project) }

                it { is_expected.not_to be_able_to(:create, issue) }
                it { is_expected.to be_able_to(:read, issue) }
                it { is_expected.to be_able_to(:update, issue) }
                it { is_expected.to be_able_to(:destroy, issue) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:project, category: category, visible: false,
                                    internal: true)
              end

              context "when belongs to them" do
                let(:issue) { Fabricate(:issue, project: project, user: admin) }

                it { is_expected.not_to be_able_to(:create, issue) }
                it { is_expected.to be_able_to(:read, issue) }
                it { is_expected.to be_able_to(:update, issue) }
                it { is_expected.to be_able_to(:destroy, issue) }
              end

              context "when doesn't belong to them" do
                let(:issue) { Fabricate(:issue, project: project) }

                it { is_expected.not_to be_able_to(:create, issue) }
                it { is_expected.to be_able_to(:read, issue) }
                it { is_expected.to be_able_to(:update, issue) }
                it { is_expected.to be_able_to(:destroy, issue) }
              end
            end
          end
        end
      end
    end

    describe "for a reviewer" do
      let(:category) { Fabricate(:category) }
      let(:project) { Fabricate(:project, category: category) }
      let(:current_user) { Fabricate(:user_reviewer) }

      subject(:ability) { Ability.new(current_user) }

      context "when issue category is visible" do
        context "and external" do
          context "while project is visible" do
            context "and external" do
              context "when belongs to them" do
                let(:issue) do
                  Fabricate(:issue, project: project, user: current_user)
                end

                it { is_expected.to be_able_to(:create, issue) }
                it { is_expected.to be_able_to(:read, issue) }
                it { is_expected.to be_able_to(:update, issue) }
                it { is_expected.not_to be_able_to(:destroy, issue) }
              end

              context "when doesn't belong to them" do
                let(:issue) { Fabricate(:issue, project: project) }

                it { is_expected.not_to be_able_to(:create, issue) }
                it { is_expected.to be_able_to(:read, issue) }
                it { is_expected.not_to be_able_to(:update, issue) }
                it { is_expected.not_to be_able_to(:destroy, issue) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:project, category: category, internal: true)
              end

              context "when belongs to them" do
                let(:issue) do
                  Fabricate(:issue, project: project, user: current_user)
                end

                it { is_expected.to be_able_to(:create, issue) }
                it { is_expected.to be_able_to(:read, issue) }
                it { is_expected.to be_able_to(:update, issue) }
                it { is_expected.not_to be_able_to(:destroy, issue) }
              end

              context "when doesn't belong to them" do
                let(:issue) { Fabricate(:issue, project: project) }

                it { is_expected.not_to be_able_to(:create, issue) }
                it { is_expected.to be_able_to(:read, issue) }
                it { is_expected.not_to be_able_to(:update, issue) }
                it { is_expected.not_to be_able_to(:destroy, issue) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:issue) do
                  Fabricate(:issue, project: project, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue) }
                it { is_expected.to be_able_to(:read, issue) }
                it { is_expected.to be_able_to(:update, issue) }
                it { is_expected.not_to be_able_to(:destroy, issue) }
              end

              context "when doesn't belong to them" do
                let(:issue) { Fabricate(:issue, project: project) }

                it { is_expected.not_to be_able_to(:create, issue) }
                it { is_expected.to be_able_to(:read, issue) }
                it { is_expected.not_to be_able_to(:update, issue) }
                it { is_expected.not_to be_able_to(:destroy, issue) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:project, category: category, visible: false,
                                    internal: true)
              end

              context "when belongs to them" do
                let(:issue) do
                  Fabricate(:issue, project: project, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue) }
                it { is_expected.to be_able_to(:read, issue) }
                it { is_expected.to be_able_to(:update, issue) }
                it { is_expected.not_to be_able_to(:destroy, issue) }
              end

              context "when doesn't belong to them" do
                let(:issue) { Fabricate(:issue, project: project) }

                it { is_expected.not_to be_able_to(:create, issue) }
                it { is_expected.to be_able_to(:read, issue) }
                it { is_expected.not_to be_able_to(:update, issue) }
                it { is_expected.not_to be_able_to(:destroy, issue) }
              end
            end
          end
        end
      end

      context "when issue category is invisible" do
        context "and external" do
          let(:category) { Fabricate(:category, visible: false) }

          context "while project is visible" do
            context "and external" do
              context "when belongs to them" do
                let(:issue) do
                  Fabricate(:issue, project: project, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue) }
                it { is_expected.to be_able_to(:read, issue) }
                it { is_expected.to be_able_to(:update, issue) }
                it { is_expected.not_to be_able_to(:destroy, issue) }
              end

              context "when doesn't belong to them" do
                let(:issue) { Fabricate(:issue, project: project) }

                it { is_expected.not_to be_able_to(:create, issue) }
                it { is_expected.to be_able_to(:read, issue) }
                it { is_expected.not_to be_able_to(:update, issue) }
                it { is_expected.not_to be_able_to(:destroy, issue) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:project, category: category, internal: true)
              end

              context "when belongs to them" do
                let(:issue) do
                  Fabricate(:issue, project: project, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue) }
                it { is_expected.to be_able_to(:read, issue) }
                it { is_expected.to be_able_to(:update, issue) }
                it { is_expected.not_to be_able_to(:destroy, issue) }
              end

              context "when doesn't belong to them" do
                let(:issue) { Fabricate(:issue, project: project) }

                it { is_expected.not_to be_able_to(:create, issue) }
                it { is_expected.to be_able_to(:read, issue) }
                it { is_expected.not_to be_able_to(:update, issue) }
                it { is_expected.not_to be_able_to(:destroy, issue) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:issue) do
                  Fabricate(:issue, project: project, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue) }
                it { is_expected.to be_able_to(:read, issue) }
                it { is_expected.to be_able_to(:update, issue) }
                it { is_expected.not_to be_able_to(:destroy, issue) }
              end

              context "when doesn't belong to them" do
                let(:issue) { Fabricate(:issue, project: project) }

                it { is_expected.not_to be_able_to(:create, issue) }
                it { is_expected.to be_able_to(:read, issue) }
                it { is_expected.not_to be_able_to(:update, issue) }
                it { is_expected.not_to be_able_to(:destroy, issue) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:project, category: category, visible: false,
                                    internal: true)
              end

              context "when belongs to them" do
                let(:issue) do
                  Fabricate(:issue, project: project, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue) }
                it { is_expected.to be_able_to(:read, issue) }
                it { is_expected.to be_able_to(:update, issue) }
                it { is_expected.not_to be_able_to(:destroy, issue) }
              end

              context "when doesn't belong to them" do
                let(:issue) { Fabricate(:issue, project: project) }

                it { is_expected.not_to be_able_to(:create, issue) }
                it { is_expected.to be_able_to(:read, issue) }
                it { is_expected.not_to be_able_to(:update, issue) }
                it { is_expected.not_to be_able_to(:destroy, issue) }
              end
            end
          end
        end
      end
    end

    %i[worker].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        let(:category) { Fabricate(:category) }
        let(:project) { Fabricate(:project, category: category) }

        subject(:ability) { Ability.new(current_user) }

        context "when category is visible" do
          context "and external" do
            context "while project is visible" do
              context "and external" do
                context "when belongs to them" do
                  let(:issue) do
                    Fabricate(:issue, project: project, user: current_user)
                  end

                  it { is_expected.to be_able_to(:create, issue) }
                  it { is_expected.to be_able_to(:read, issue) }
                  it { is_expected.to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end

                context "when doesn't belong to them" do
                  let(:issue) { Fabricate(:issue, project: project) }

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, internal: true)
                end

                context "when belongs to them" do
                  let(:issue) do
                    Fabricate(:issue, project: project, user: current_user)
                  end

                  it { is_expected.to be_able_to(:create, issue) }
                  it { is_expected.to be_able_to(:read, issue) }
                  it { is_expected.to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end

                context "when doesn't belong to them" do
                  let(:issue) { Fabricate(:issue, project: project) }

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end
              end
            end

            context "while project is invisible" do
              context "and external" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: false)
                end

                context "when belongs to them" do
                  let(:issue) do
                    Fabricate(:issue, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.not_to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end

                context "when doesn't belong to them" do
                  let(:issue) { Fabricate(:issue, project: project) }

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.not_to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: true)
                end

                context "when belongs to them" do
                  let(:issue) do
                    Fabricate(:issue, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.not_to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end

                context "when doesn't belong to them" do
                  let(:issue) { Fabricate(:issue, project: project) }

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.not_to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end
              end
            end
          end
        end

        context "when category is invisible" do
          context "and external" do
            let(:category) { Fabricate(:category, visible: false) }

            context "while project is visible" do
              context "and external" do
                context "when belongs to them" do
                  let(:issue) do
                    Fabricate(:issue, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.not_to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end

                context "when doesn't belong to them" do
                  let(:issue) { Fabricate(:issue, project: project) }

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.not_to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, internal: true)
                end

                context "when belongs to them" do
                  let(:issue) do
                    Fabricate(:issue, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.not_to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end

                context "when doesn't belong to them" do
                  let(:issue) { Fabricate(:issue, project: project) }

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.not_to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end
              end
            end

            context "while project is invisible" do
              context "and external" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: false)
                end

                context "when belongs to them" do
                  let(:issue) do
                    Fabricate(:issue, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.not_to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end

                context "when doesn't belong to them" do
                  let(:issue) { Fabricate(:issue, project: project) }

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.not_to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: true)
                end

                context "when belongs to them" do
                  let(:issue) do
                    Fabricate(:issue, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.not_to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end

                context "when doesn't belong to them" do
                  let(:issue) { Fabricate(:issue, project: project) }

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.not_to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end
              end
            end
          end

          context "and internal" do
            let(:category) do
              Fabricate(:category, visible: true, internal: true)
            end

            context "while project is visible" do
              context "and external" do
                context "when belongs to them" do
                  let(:issue) do
                    Fabricate(:issue, project: project, user: current_user)
                  end

                  it { is_expected.to be_able_to(:create, issue) }
                  it { is_expected.to be_able_to(:read, issue) }
                  it { is_expected.to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end

                context "when doesn't belong to them" do
                  let(:issue) { Fabricate(:issue, project: project) }

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, internal: true)
                end

                context "when belongs to them" do
                  let(:issue) do
                    Fabricate(:issue, project: project, user: current_user)
                  end

                  it { is_expected.to be_able_to(:create, issue) }
                  it { is_expected.to be_able_to(:read, issue) }
                  it { is_expected.to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end

                context "when doesn't belong to them" do
                  let(:issue) { Fabricate(:issue, project: project) }

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end
              end
            end

            context "while project is invisible" do
              context "and external" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: false)
                end

                context "when belongs to them" do
                  let(:issue) do
                    Fabricate(:issue, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.not_to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end

                context "when doesn't belong to them" do
                  let(:issue) { Fabricate(:issue, project: project) }

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.not_to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: true)
                end

                context "when belongs to them" do
                  let(:issue) do
                    Fabricate(:issue, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.not_to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end

                context "when doesn't belong to them" do
                  let(:issue) { Fabricate(:issue, project: project) }

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.not_to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end
              end
            end
          end
        end
      end
    end

    %i[reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        let(:category) { Fabricate(:category) }
        let(:project) { Fabricate(:project, category: category) }

        subject(:ability) { Ability.new(current_user) }

        context "when category is visible" do
          context "and external" do
            context "while project is visible" do
              context "and external" do
                context "when belongs to them" do
                  let(:issue) do
                    Fabricate(:issue, project: project, user: current_user)
                  end

                  it { is_expected.to be_able_to(:create, issue) }
                  it { is_expected.to be_able_to(:read, issue) }
                  it { is_expected.to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end

                context "when doesn't belong to them" do
                  let(:issue) { Fabricate(:issue, project: project) }

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, internal: true)
                end

                context "when belongs to them" do
                  let(:issue) do
                    Fabricate(:issue, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.not_to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end

                context "when doesn't belong to them" do
                  let(:issue) { Fabricate(:issue, project: project) }

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.not_to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end
              end
            end

            context "while project is invisible" do
              context "and external" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: false)
                end

                context "when belongs to them" do
                  let(:issue) do
                    Fabricate(:issue, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.not_to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end

                context "when doesn't belong to them" do
                  let(:issue) { Fabricate(:issue, project: project) }

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.not_to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: true)
                end

                context "when belongs to them" do
                  let(:issue) do
                    Fabricate(:issue, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.not_to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end

                context "when doesn't belong to them" do
                  let(:issue) { Fabricate(:issue, project: project) }

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.not_to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end
              end
            end
          end
        end

        context "when category is invisible" do
          context "and external" do
            let(:category) { Fabricate(:category, visible: false) }

            context "while project is visible" do
              context "and external" do
                context "when belongs to them" do
                  let(:issue) do
                    Fabricate(:issue, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.not_to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end

                context "when doesn't belong to them" do
                  let(:issue) { Fabricate(:issue, project: project) }

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.not_to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, internal: true)
                end

                context "when belongs to them" do
                  let(:issue) do
                    Fabricate(:issue, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.not_to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end

                context "when doesn't belong to them" do
                  let(:issue) { Fabricate(:issue, project: project) }

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.not_to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end
              end
            end

            context "while project is invisible" do
              context "and external" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: false)
                end

                context "when belongs to them" do
                  let(:issue) do
                    Fabricate(:issue, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.not_to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end

                context "when doesn't belong to them" do
                  let(:issue) { Fabricate(:issue, project: project) }

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.not_to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: true)
                end

                context "when belongs to them" do
                  let(:issue) do
                    Fabricate(:issue, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.not_to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end

                context "when doesn't belong to them" do
                  let(:issue) { Fabricate(:issue, project: project) }

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.not_to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end
              end
            end
          end

          context "and internal" do
            let(:category) do
              Fabricate(:category, visible: true, internal: true)
            end

            context "while project is visible" do
              context "and external" do
                context "when belongs to them" do
                  let(:issue) do
                    Fabricate(:issue, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.not_to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end

                context "when doesn't belong to them" do
                  let(:issue) { Fabricate(:issue, project: project) }

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.not_to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, internal: true)
                end

                context "when belongs to them" do
                  let(:issue) do
                    Fabricate(:issue, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.not_to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end

                context "when doesn't belong to them" do
                  let(:issue) { Fabricate(:issue, project: project) }

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.not_to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end
              end
            end

            context "while project is invisible" do
              context "and external" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: false)
                end

                context "when belongs to them" do
                  let(:issue) do
                    Fabricate(:issue, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.not_to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end

                context "when doesn't belong to them" do
                  let(:issue) { Fabricate(:issue, project: project) }

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.not_to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: true)
                end

                context "when belongs to them" do
                  let(:issue) do
                    Fabricate(:issue, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.not_to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end

                context "when doesn't belong to them" do
                  let(:issue) { Fabricate(:issue, project: project) }

                  it { is_expected.not_to be_able_to(:create, issue) }
                  it { is_expected.not_to be_able_to(:read, issue) }
                  it { is_expected.not_to be_able_to(:update, issue) }
                  it { is_expected.not_to be_able_to(:destroy, issue) }
                end
              end
            end
          end
        end
      end
    end
  end

  describe "IssueClosure model" do
    %i[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        subject(:ability) { Ability.new(current_user) }

        context "when their closure" do
          let(:issue_closure) { Fabricate(:issue_closure, user: current_user) }

          it { is_expected.to be_able_to(:create, issue_closure) }
          it { is_expected.to be_able_to(:read, issue_closure) }
          it { is_expected.not_to be_able_to(:update, issue_closure) }
          it { is_expected.to be_able_to(:destroy, issue_closure) }
        end

        context "when someone else's closure" do
          let(:issue_closure) { Fabricate(:issue_closure) }

          it { is_expected.not_to be_able_to(:create, issue_closure) }
          it { is_expected.to be_able_to(:read, issue_closure) }
          it { is_expected.not_to be_able_to(:update, issue_closure) }
          it { is_expected.to be_able_to(:destroy, issue_closure) }
        end
      end
    end

    %i[reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        subject(:ability) { Ability.new(current_user) }

        context "when their closure" do
          let(:issue_closure) { Fabricate(:issue_closure, user: current_user) }

          it { is_expected.to be_able_to(:create, issue_closure) }
          it { is_expected.to be_able_to(:read, issue_closure) }
          it { is_expected.not_to be_able_to(:update, issue_closure) }
          it { is_expected.not_to be_able_to(:destroy, issue_closure) }
        end

        context "when someone else's closure" do
          let(:issue_closure) { Fabricate(:issue_closure) }

          it { is_expected.not_to be_able_to(:create, issue_closure) }
          it { is_expected.to be_able_to(:read, issue_closure) }
          it { is_expected.not_to be_able_to(:update, issue_closure) }
          it { is_expected.not_to be_able_to(:destroy, issue_closure) }
        end
      end
    end

    %i[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        let(:issue_closure) { Fabricate(:issue_closure, user: current_user) }

        subject(:ability) { Ability.new(current_user) }

        it { is_expected.not_to be_able_to(:create, issue_closure) }
        it { is_expected.to be_able_to(:read, issue_closure) }
        it { is_expected.not_to be_able_to(:update, issue_closure) }
        it { is_expected.not_to be_able_to(:destroy, issue_closure) }
      end
    end
  end

  describe "IssueComment model" do
    describe "for an admin" do
      let(:issue) { Fabricate(:issue, project: project) }
      let(:admin) { Fabricate(:user_admin) }
      subject(:ability) { Ability.new(admin) }

      context "when category is visible" do
        context "and external" do
          let(:category) { Fabricate(:category) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: admin)
                end

                it { is_expected.to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.to be_able_to(:update, issue_comment) }
                it { is_expected.to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.to be_able_to(:update, issue_comment) }
                it { is_expected.to be_able_to(:destroy, issue_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: admin)
                end

                it { is_expected.to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.to be_able_to(:update, issue_comment) }
                it { is_expected.to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.to be_able_to(:update, issue_comment) }
                it { is_expected.to be_able_to(:destroy, issue_comment) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:invisible_project, category: category)
              end

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: admin)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.to be_able_to(:update, issue_comment) }
                it { is_expected.to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.to be_able_to(:update, issue_comment) }
                it { is_expected.to be_able_to(:destroy, issue_comment) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:internal_project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: admin)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.to be_able_to(:update, issue_comment) }
                it { is_expected.to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.to be_able_to(:update, issue_comment) }
                it { is_expected.to be_able_to(:destroy, issue_comment) }
              end
            end
          end
        end

        context "and internal" do
          let(:category) { Fabricate(:internal_category) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: admin)
                end

                it { is_expected.to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.to be_able_to(:update, issue_comment) }
                it { is_expected.to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.to be_able_to(:update, issue_comment) }
                it { is_expected.to be_able_to(:destroy, issue_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: admin)
                end

                it { is_expected.to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.to be_able_to(:update, issue_comment) }
                it { is_expected.to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.to be_able_to(:update, issue_comment) }
                it { is_expected.to be_able_to(:destroy, issue_comment) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:invisible_project, category: category)
              end

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: admin)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.to be_able_to(:update, issue_comment) }
                it { is_expected.to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.to be_able_to(:update, issue_comment) }
                it { is_expected.to be_able_to(:destroy, issue_comment) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:internal_project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: admin)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.to be_able_to(:update, issue_comment) }
                it { is_expected.to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.to be_able_to(:update, issue_comment) }
                it { is_expected.to be_able_to(:destroy, issue_comment) }
              end
            end
          end
        end
      end

      context "when category is invisible" do
        context "and external" do
          let(:category) { Fabricate(:invisible_category) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: admin)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.to be_able_to(:update, issue_comment) }
                it { is_expected.to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.to be_able_to(:update, issue_comment) }
                it { is_expected.to be_able_to(:destroy, issue_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: admin)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.to be_able_to(:update, issue_comment) }
                it { is_expected.to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.to be_able_to(:update, issue_comment) }
                it { is_expected.to be_able_to(:destroy, issue_comment) }
              end
            end
          end
        end

        context "and internal" do
          let(:category) { Fabricate(:invisible_category, internal: true) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: admin)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.to be_able_to(:update, issue_comment) }
                it { is_expected.to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.to be_able_to(:update, issue_comment) }
                it { is_expected.to be_able_to(:destroy, issue_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: admin)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.to be_able_to(:update, issue_comment) }
                it { is_expected.to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.to be_able_to(:update, issue_comment) }
                it { is_expected.to be_able_to(:destroy, issue_comment) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:invisible_project, category: category)
              end

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: admin)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.to be_able_to(:update, issue_comment) }
                it { is_expected.to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.to be_able_to(:update, issue_comment) }
                it { is_expected.to be_able_to(:destroy, issue_comment) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:internal_project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: admin)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.to be_able_to(:update, issue_comment) }
                it { is_expected.to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.to be_able_to(:update, issue_comment) }
                it { is_expected.to be_able_to(:destroy, issue_comment) }
              end
            end
          end
        end
      end
    end

    describe "for a reviewer" do
      let(:issue) { Fabricate(:issue, project: project) }
      let(:current_user) { Fabricate(:user_reviewer) }
      subject(:ability) { Ability.new(current_user) }

      context "when category is visible" do
        context "and external" do
          let(:category) { Fabricate(:category) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:invisible_project, category: category)
              end

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:internal_project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end
          end
        end

        context "and internal" do
          let(:category) { Fabricate(:internal_category) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:invisible_project, category: category)
              end

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:internal_project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end
          end
        end
      end

      context "when category is invisible" do
        context "and external" do
          let(:category) { Fabricate(:invisible_category) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end
          end
        end

        context "and internal" do
          let(:category) { Fabricate(:invisible_category, internal: true) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:invisible_project, category: category)
              end

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:internal_project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end
          end
        end
      end
    end

    describe "for a worker" do
      let(:issue) { Fabricate(:issue, project: project) }
      let(:current_user) { Fabricate(:user_worker) }
      subject(:ability) { Ability.new(current_user) }

      context "when category is visible" do
        context "and external" do
          let(:category) { Fabricate(:category) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:invisible_project, category: category)
              end

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:internal_project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end
          end
        end

        context "and internal" do
          let(:category) { Fabricate(:internal_category) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:invisible_project, category: category)
              end

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:internal_project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end
          end
        end
      end

      context "when category is invisible" do
        context "and external" do
          let(:category) { Fabricate(:invisible_category) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end
          end
        end

        context "and internal" do
          let(:category) { Fabricate(:invisible_category, internal: true) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:invisible_project, category: category)
              end

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:internal_project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end
          end
        end
      end
    end

    describe "for a reporter" do
      let(:issue) { Fabricate(:issue, project: project) }
      let(:current_user) { Fabricate(:user_reporter) }
      subject(:ability) { Ability.new(current_user) }

      context "when category is visible" do
        context "and external" do
          let(:category) { Fabricate(:category) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:invisible_project, category: category)
              end

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:internal_project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end
          end
        end

        context "and internal" do
          let(:category) { Fabricate(:internal_category) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:invisible_project, category: category)
              end

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:internal_project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end
          end
        end
      end

      context "when category is invisible" do
        context "and external" do
          let(:category) { Fabricate(:invisible_category) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end
          end
        end

        context "and internal" do
          let(:category) { Fabricate(:invisible_category, internal: true) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:invisible_project, category: category)
              end

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:internal_project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:issue_comment) do
                  Fabricate(:issue_comment, issue: issue, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end

              context "when doesn't belong to them" do
                let(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

                it { is_expected.not_to be_able_to(:create, issue_comment) }
                it { is_expected.not_to be_able_to(:read, issue_comment) }
                it { is_expected.not_to be_able_to(:update, issue_comment) }
                it { is_expected.not_to be_able_to(:destroy, issue_comment) }
              end
            end
          end
        end
      end
    end
  end

  describe "IssueConnection model" do
    %i[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        subject(:ability) { Ability.new(current_user) }

        context "when their connection" do
          let(:issue_connection) do
            Fabricate(:issue_connection, user: current_user)
          end

          it { is_expected.to be_able_to(:create, issue_connection) }
          it { is_expected.to be_able_to(:read, issue_connection) }
          it { is_expected.to be_able_to(:update, issue_connection) }
          it { is_expected.to be_able_to(:destroy, issue_connection) }
        end

        context "when someone else's connection" do
          let(:issue_connection) { Fabricate(:issue_connection) }

          it { is_expected.not_to be_able_to(:create, issue_connection) }
          it { is_expected.to be_able_to(:read, issue_connection) }
          it { is_expected.not_to be_able_to(:update, issue_connection) }
          it { is_expected.to be_able_to(:destroy, issue_connection) }
        end
      end
    end

    %i[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        let(:issue_connection) do
          Fabricate(:issue_connection, user: current_user)
        end

        subject(:ability) { Ability.new(current_user) }

        it { is_expected.not_to be_able_to(:create, issue_connection) }
        it { is_expected.to be_able_to(:read, issue_connection) }
        it { is_expected.not_to be_able_to(:update, issue_connection) }
        it { is_expected.not_to be_able_to(:destroy, issue_connection) }
      end
    end
  end

  describe "IssueReopening model" do
    %i[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        subject(:ability) { Ability.new(current_user) }

        context "when their closure" do
          let(:issue_reopening) do
            Fabricate(:issue_reopening, user: current_user)
          end

          it { is_expected.to be_able_to(:create, issue_reopening) }
          it { is_expected.to be_able_to(:read, issue_reopening) }
          it { is_expected.not_to be_able_to(:update, issue_reopening) }
          it { is_expected.to be_able_to(:destroy, issue_reopening) }
        end

        context "when someone else's reopening" do
          let(:issue_reopening) { Fabricate(:issue_reopening) }

          it { is_expected.not_to be_able_to(:create, issue_reopening) }
          it { is_expected.to be_able_to(:read, issue_reopening) }
          it { is_expected.not_to be_able_to(:update, issue_reopening) }
          it { is_expected.to be_able_to(:destroy, issue_reopening) }
        end
      end
    end

    %i[reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        subject(:ability) { Ability.new(current_user) }

        context "when their reopening" do
          let(:issue_reopening) do
            Fabricate(:issue_reopening, user: current_user)
          end

          it { is_expected.to be_able_to(:create, issue_reopening) }
          it { is_expected.to be_able_to(:read, issue_reopening) }
          it { is_expected.not_to be_able_to(:update, issue_reopening) }
          it { is_expected.not_to be_able_to(:destroy, issue_reopening) }
        end

        context "when someone else's reopening" do
          let(:issue_reopening) { Fabricate(:issue_reopening) }

          it { is_expected.not_to be_able_to(:create, issue_reopening) }
          it { is_expected.to be_able_to(:read, issue_reopening) }
          it { is_expected.not_to be_able_to(:update, issue_reopening) }
          it { is_expected.not_to be_able_to(:destroy, issue_reopening) }
        end
      end
    end

    %i[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        let(:issue_reopening) do
          Fabricate(:issue_reopening, user: current_user)
        end

        subject(:ability) { Ability.new(current_user) }

        it { is_expected.not_to be_able_to(:create, issue_reopening) }
        it { is_expected.to be_able_to(:read, issue_reopening) }
        it { is_expected.not_to be_able_to(:update, issue_reopening) }
        it { is_expected.not_to be_able_to(:destroy, issue_reopening) }
      end
    end
  end

  describe "IssueSubscription model" do
    describe "for an admin" do
      let(:admin) { Fabricate(:user_admin) }
      subject(:ability) { Ability.new(admin) }

      context "when belongs to them" do
        let(:issue_subscription) { Fabricate(:issue_subscription, user: admin) }

        it { is_expected.to be_able_to(:create, issue_subscription) }
        it { is_expected.to be_able_to(:read, issue_subscription) }
        it { is_expected.to be_able_to(:update, issue_subscription) }
        it { is_expected.to be_able_to(:destroy, issue_subscription) }
      end

      context "when doesn't belong to them" do
        let(:issue_subscription) { Fabricate(:issue_subscription) }

        it { is_expected.not_to be_able_to(:create, issue_subscription) }
        it { is_expected.not_to be_able_to(:read, issue_subscription) }
        it { is_expected.not_to be_able_to(:update, issue_subscription) }
        it { is_expected.not_to be_able_to(:destroy, issue_subscription) }
      end
    end

    %i[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        context "when belongs to them" do
          let(:issue_subscription) do
            Fabricate(:issue_subscription, user: current_user)
          end

          it { is_expected.to be_able_to(:create, issue_subscription) }
          it { is_expected.to be_able_to(:read, issue_subscription) }
          it { is_expected.to be_able_to(:update, issue_subscription) }
          it { is_expected.to be_able_to(:destroy, issue_subscription) }
        end

        context "when doesn't belong to them" do
          let(:issue_subscription) { Fabricate(:issue_subscription) }

          it { is_expected.not_to be_able_to(:create, issue_subscription) }
          it { is_expected.not_to be_able_to(:read, issue_subscription) }
          it { is_expected.not_to be_able_to(:update, issue_subscription) }
          it { is_expected.not_to be_able_to(:destroy, issue_subscription) }
        end
      end
    end
  end

  describe "IssueType model" do
    let(:issue_type) { Fabricate(:issue_type) }

    %i[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        it { is_expected.to be_able_to(:create, issue_type) }
        it { is_expected.to be_able_to(:read, issue_type) }
        it { is_expected.to be_able_to(:update, issue_type) }
        it { is_expected.to be_able_to(:destroy, issue_type) }
      end
    end

    %i[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        it { is_expected.not_to be_able_to(:create, issue_type) }
        it { is_expected.not_to be_able_to(:read, issue_type) }
        it { is_expected.not_to be_able_to(:update, issue_type) }
        it { is_expected.not_to be_able_to(:destroy, issue_type) }
      end
    end
  end

  describe "Progression model" do
    let(:task) { Fabricate(:task) }

    describe "for an admin" do
      let(:admin) { Fabricate(:user_admin) }
      subject(:ability) { Ability.new(admin) }

      context "when assigned to the task" do
        let(:progression) { Fabricate(:progression, task: task, user: admin) }

        before { task.assignees << admin }

        it { is_expected.to be_able_to(:create, progression) }
      end

      context "when not assigned to the task" do
        let(:progression) { Fabricate(:progression, task: task, user: admin) }

        it { is_expected.not_to be_able_to(:create, progression) }
      end

      context "when belongs to them" do
        let(:progression) { Fabricate(:progression, user: admin) }

        it { is_expected.to be_able_to(:read, progression) }
        it { is_expected.to be_able_to(:update, progression) }
        it { is_expected.to be_able_to(:destroy, progression) }
        it { is_expected.to be_able_to(:finish, progression) }
      end

      context "when doesn't belong to them" do
        let(:progression) { Fabricate(:progression, task: task) }

        it { is_expected.to be_able_to(:read, progression) }
        it { is_expected.to be_able_to(:update, progression) }
        it { is_expected.to be_able_to(:destroy, progression) }
        it { is_expected.not_to be_able_to(:finish, progression) }
      end

      context "when no task" do
        let(:progression) { Fabricate(:progression, task: task, user: admin) }

        before do
          task.assignees << admin
          progression.update_attribute :task_id, 0
        end

        it { is_expected.not_to be_able_to(:create, progression) }
      end
    end

    %i[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        context "when assigned to the task" do
          let(:progression) do
            Fabricate(:progression, task: task, user: current_user)
          end

          before { task.assignees << current_user }

          it { is_expected.to be_able_to(:create, progression) }
        end

        context "when not assigned to the task" do
          let(:progression) do
            Fabricate(:progression, task: task, user: current_user)
          end

          it { is_expected.not_to be_able_to(:create, progression) }
        end

        context "when belongs to them" do
          let(:progression) { Fabricate(:progression, user: current_user) }

          it { is_expected.to be_able_to(:read, progression) }
          it { is_expected.not_to be_able_to(:update, progression) }
          it { is_expected.to be_able_to(:finish, progression) }
          it { is_expected.not_to be_able_to(:destroy, progression) }
        end

        context "when doesn't belong to them" do
          let(:progression) { Fabricate(:progression, task: task) }

          it { is_expected.to be_able_to(:read, progression) }
          it { is_expected.not_to be_able_to(:update, progression) }
          it { is_expected.not_to be_able_to(:finish, progression) }
          it { is_expected.not_to be_able_to(:destroy, progression) }
        end

        context "when no task" do
          let(:progression) do
            Fabricate(:progression, task: task, user: current_user)
          end

          before do
            task.assignees << current_user
            progression.update_attribute :task_id, 0
          end

          it { is_expected.not_to be_able_to(:create, progression) }
        end
      end
    end
  end

  describe "Project model" do
    describe "for an admin" do
      let(:current_user) { Fabricate(:user_admin) }

      subject(:ability) { Ability.new(current_user) }

      context "when category/project are invisible and internal" do
        let(:category) { Fabricate(:category, visible: false, internal: true) }
        let(:project) do
          Fabricate(:project, category: category, visible: false,
                              internal: true)
        end

        it { is_expected.to be_able_to(:create, project) }
        it { is_expected.to be_able_to(:read, project) }
        it { is_expected.to be_able_to(:update, project) }
        it { is_expected.to be_able_to(:destroy, project) }
      end
    end

    context "for a reviewer" do
      let(:current_user) { Fabricate("user_reviewer") }

      subject(:ability) { Ability.new(current_user) }

      context "when category/project are invisible and internal" do
        let(:category) { Fabricate(:category, visible: false, internal: true) }
        let(:project) do
          Fabricate(:project, category: category, visible: false,
                              internal: true)
        end
        let(:project) { Fabricate(:project, visible: false, internal: true) }

        it { is_expected.to be_able_to(:create, project) }
        it { is_expected.to be_able_to(:read, project) }
        it { is_expected.to be_able_to(:update, project) }
        it { is_expected.not_to be_able_to(:destroy, project) }
      end
    end

    %i[worker].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        context "when project is visible" do
          context "and external" do
            let(:project) do
              Fabricate(:project, visible: true, internal: false)
            end

            it { is_expected.not_to be_able_to(:create, project) }
            it { is_expected.to be_able_to(:read, project) }
            it { is_expected.not_to be_able_to(:update, project) }
            it { is_expected.not_to be_able_to(:destroy, project) }
          end

          context "and internal" do
            let(:project) do
              Fabricate(:project, visible: true, internal: true)
            end

            it { is_expected.not_to be_able_to(:create, project) }
            it { is_expected.to be_able_to(:read, project) }
            it { is_expected.not_to be_able_to(:update, project) }
            it { is_expected.not_to be_able_to(:destroy, project) }
          end
        end

        context "and project is invisible" do
          context "and external" do
            let(:project) do
              Fabricate(:project, visible: false,
                                  internal: false)
            end

            it { is_expected.not_to be_able_to(:create, project) }
            it { is_expected.not_to be_able_to(:read, project) }
            it { is_expected.not_to be_able_to(:update, project) }
            it { is_expected.not_to be_able_to(:destroy, project) }
          end

          context "and internal" do
            let(:project) do
              Fabricate(:project, visible: false, internal: true)
            end

            it { is_expected.not_to be_able_to(:create, project) }
            it { is_expected.not_to be_able_to(:read, project) }
            it { is_expected.not_to be_able_to(:update, project) }
            it { is_expected.not_to be_able_to(:destroy, project) }
          end
        end

        context "when project category is internal" do
          context "while project is visible and external" do
            let(:category) do
              Fabricate(:category, visible: true, internal: true)
            end
            let(:project) do
              Fabricate(:project, category: category, visible: true,
                                  internal: false)
            end

            it { is_expected.not_to be_able_to(:create, project) }
            it { is_expected.to be_able_to(:read, project) }
            it { is_expected.not_to be_able_to(:update, project) }
            it { is_expected.not_to be_able_to(:destroy, project) }
          end
        end

        context "when project category is invisible" do
          context "while project is visible and external" do
            let(:category) do
              Fabricate(:category, visible: false, internal: false)
            end
            let(:project) do
              Fabricate(:project, category: category, visible: true,
                                  internal: false)
            end

            it { is_expected.not_to be_able_to(:create, project) }
            it { is_expected.not_to be_able_to(:read, project) }
            it { is_expected.not_to be_able_to(:update, project) }
            it { is_expected.not_to be_able_to(:destroy, project) }
          end
        end
      end
    end

    %i[reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        context "when project is visible" do
          context "and external" do
            let(:project) do
              Fabricate(:project, visible: true, internal: false)
            end

            it { is_expected.not_to be_able_to(:create, project) }
            it { is_expected.to be_able_to(:read, project) }
            it { is_expected.not_to be_able_to(:update, project) }
            it { is_expected.not_to be_able_to(:destroy, project) }
          end

          context "and internal" do
            let(:project) do
              Fabricate(:project, visible: true, internal: true)
            end

            it { is_expected.not_to be_able_to(:create, project) }
            it { is_expected.not_to be_able_to(:read, project) }
            it { is_expected.not_to be_able_to(:update, project) }
            it { is_expected.not_to be_able_to(:destroy, project) }
          end
        end

        context "and project is invisible" do
          context "and external" do
            let(:project) do
              Fabricate(:project, visible: false, internal: false)
            end

            it { is_expected.not_to be_able_to(:create, project) }
            it { is_expected.not_to be_able_to(:read, project) }
            it { is_expected.not_to be_able_to(:update, project) }
            it { is_expected.not_to be_able_to(:destroy, project) }
          end

          context "and internal" do
            let(:project) do
              Fabricate(:project, visible: false, internal: true)
            end

            it { is_expected.not_to be_able_to(:create, project) }
            it { is_expected.not_to be_able_to(:read, project) }
            it { is_expected.not_to be_able_to(:update, project) }
            it { is_expected.not_to be_able_to(:destroy, project) }
          end
        end

        context "when project category is internal" do
          context "while project is visible and external" do
            let(:category) do
              Fabricate(:category, visible: true, internal: true)
            end
            let(:project) do
              Fabricate(:project, category: category, visible: true,
                                  internal: false)
            end

            it { is_expected.not_to be_able_to(:create, project) }
            it { is_expected.not_to be_able_to(:read, project) }
            it { is_expected.not_to be_able_to(:update, project) }
            it { is_expected.not_to be_able_to(:destroy, project) }
          end
        end

        context "when project category is invisible" do
          context "while project is visible and external" do
            let(:category) do
              Fabricate(:category, visible: false, internal: false)
            end
            let(:project) do
              Fabricate(:project, category: category, visible: true,
                                  internal: false)
            end

            it { is_expected.not_to be_able_to(:create, project) }
            it { is_expected.not_to be_able_to(:read, project) }
            it { is_expected.not_to be_able_to(:update, project) }
            it { is_expected.not_to be_able_to(:destroy, project) }
          end
        end
      end
    end
  end

  describe "ProjectIssuesSubscription model" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        context "when belongs to them" do
          let(:subscription) do
            Fabricate(:project_issues_subscription, user: current_user)
          end

          it { is_expected.to be_able_to(:create, subscription) }
          it { is_expected.to be_able_to(:read, subscription) }
          it { is_expected.to be_able_to(:update, subscription) }
          it { is_expected.to be_able_to(:destroy, subscription) }
        end

        context "when doesn't belong to them" do
          let(:subscription) { Fabricate(:project_issues_subscription) }

          it { is_expected.not_to be_able_to(:create, subscription) }
          it { is_expected.not_to be_able_to(:read, subscription) }
          it { is_expected.not_to be_able_to(:update, subscription) }
          it { is_expected.not_to be_able_to(:destroy, subscription) }
        end
      end
    end
  end

  describe "ProjectTasksSubscription model" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        context "when belongs to them" do
          let(:subscription) do
            Fabricate(:project_tasks_subscription, user: current_user)
          end

          it { is_expected.to be_able_to(:create, subscription) }
          it { is_expected.to be_able_to(:read, subscription) }
          it { is_expected.to be_able_to(:update, subscription) }
          it { is_expected.to be_able_to(:destroy, subscription) }
        end

        context "when doesn't belong to them" do
          let(:subscription) { Fabricate(:project_tasks_subscription) }

          it { is_expected.not_to be_able_to(:create, subscription) }
          it { is_expected.not_to be_able_to(:read, subscription) }
          it { is_expected.not_to be_able_to(:update, subscription) }
          it { is_expected.not_to be_able_to(:destroy, subscription) }
        end
      end
    end
  end

  describe "Resolution model" do
    describe "for an admin" do
      let(:admin) { Fabricate(:user_admin) }
      subject(:ability) { Ability.new(admin) }

      context "when resolution/issue belong to them" do
        let(:issue) { Fabricate(:issue, user: admin) }
        let(:resolution) { Fabricate(:resolution, issue: issue, user: admin) }

        it { is_expected.to be_able_to(:create, resolution) }
        it { is_expected.to be_able_to(:read, resolution) }
        it { is_expected.to be_able_to(:update, resolution) }
        it { is_expected.to be_able_to(:destroy, resolution) }
      end

      context "when issue doesn't belong to them" do
        let(:issue) { Fabricate(:issue) }
        let(:resolution) { Fabricate(:resolution, issue: issue, user: admin) }

        it { is_expected.not_to be_able_to(:create, resolution) }
        it { is_expected.to be_able_to(:read, resolution) }
        it { is_expected.to be_able_to(:update, resolution) }
        it { is_expected.to be_able_to(:destroy, resolution) }
      end

      context "when resolution doesn't belong to them" do
        let(:issue) { Fabricate(:issue, user: admin) }
        let(:resolution) { Fabricate(:resolution, issue: issue) }

        it { is_expected.not_to be_able_to(:create, resolution) }
        it { is_expected.to be_able_to(:read, resolution) }
        it { is_expected.to be_able_to(:update, resolution) }
        it { is_expected.to be_able_to(:destroy, resolution) }
      end
    end

    %i[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        context "when resolution/issue belong to them" do
          let(:issue) { Fabricate(:issue, user: current_user) }
          let(:resolution) do
            Fabricate(:resolution, issue: issue, user: current_user)
          end

          it { is_expected.to be_able_to(:create, resolution) }
          it { is_expected.to be_able_to(:read, resolution) }
          it { is_expected.not_to be_able_to(:update, resolution) }
          it { is_expected.not_to be_able_to(:destroy, resolution) }
        end

        context "when resolution doesn't belong to them" do
          let(:issue) { Fabricate(:issue, user: current_user) }
          let(:resolution) { Fabricate(:resolution, issue: issue) }

          it { is_expected.not_to be_able_to(:create, resolution) }
          it { is_expected.to be_able_to(:read, resolution) }
          it { is_expected.not_to be_able_to(:update, resolution) }
          it { is_expected.not_to be_able_to(:destroy, resolution) }
        end

        context "when issue doesn't belong to them" do
          let(:issue) { Fabricate(:issue) }
          let(:resolution) { Fabricate(:resolution, issue: issue) }

          it { is_expected.not_to be_able_to(:create, resolution) }
          it { is_expected.to be_able_to(:read, resolution) }
          it { is_expected.not_to be_able_to(:update, resolution) }
          it { is_expected.not_to be_able_to(:destroy, resolution) }
        end
      end
    end
  end

  describe "Review model" do
    let(:task) { Fabricate(:task) }

    describe "for an admin" do
      let(:admin) { Fabricate(:user_admin) }
      subject(:ability) { Ability.new(admin) }

      context "when assigned to the task" do
        let(:review) { Fabricate.build(:review, task: task, user: admin) }

        before { task.assignees << admin }

        it { is_expected.to be_able_to(:create, review) }
      end

      context "when not assigned to the task" do
        let(:review) { Fabricate.build(:review, task: task, user: admin) }

        it { is_expected.not_to be_able_to(:create, review) }
      end

      context "when belongs to them" do
        let(:review) { Fabricate(:review, task: task, user: admin) }

        it { is_expected.to be_able_to(:read, review) }
        it { is_expected.to be_able_to(:update, review) }
        it { is_expected.to be_able_to(:approve, review) }
        it { is_expected.to be_able_to(:disapprove, review) }
      end

      context "when doesn't belong to them" do
        let(:review) { Fabricate(:review, task: task) }

        it { is_expected.to be_able_to(:read, review) }
        it { is_expected.to be_able_to(:update, review) }
        it { is_expected.not_to be_able_to(:destroy, review) }
        it { is_expected.to be_able_to(:approve, review) }
        it { is_expected.to be_able_to(:disapprove, review) }
      end

      context "when their review is pending" do
        context "and task is open" do
          let(:review) { Fabricate(:review, task: task, user: admin) }

          it { is_expected.to be_able_to(:destroy, review) }
        end

        context "and task is closed" do
          let(:task) { Fabricate(:closed_task) }
          let(:review) { Fabricate(:review, task: task, user: admin) }

          it { is_expected.not_to be_able_to(:destroy, review) }
        end
      end

      context "when their review is already approved" do
        let(:review) { Fabricate(:approved_review, task: task, user: admin) }

        it { is_expected.not_to be_able_to(:destroy, review) }
      end

      context "when their review is already disapproved" do
        let(:review) { Fabricate(:disapproved_review, task: task, user: admin) }

        it { is_expected.not_to be_able_to(:destroy, review) }
      end

      context "when review is pending" do
        let(:review) { Fabricate(:review, task: task) }

        it { is_expected.to be_able_to(:approve, review) }
        it { is_expected.to be_able_to(:disapprove, review) }
      end

      context "when review is already approved" do
        let(:review) { Fabricate(:approved_review, task: task) }

        it { is_expected.not_to be_able_to(:approve, review) }
        it { is_expected.not_to be_able_to(:disapprove, review) }
      end

      context "when review is already disapproved" do
        let(:review) { Fabricate(:disapproved_review, task: task) }

        it { is_expected.not_to be_able_to(:approve, review) }
        it { is_expected.not_to be_able_to(:disapprove, review) }
      end
    end

    %i[reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        context "when assigned to the task" do
          let(:review) do
            Fabricate.build(:review, task: task, user: current_user)
          end

          before { task.assignees << current_user }

          it { is_expected.to be_able_to(:create, review) }
        end

        context "when not assigned to the task" do
          let(:review) do
            Fabricate.build(:review, task: task, user: current_user)
          end

          it { is_expected.not_to be_able_to(:create, review) }
        end

        context "when belongs to them" do
          let(:review) { Fabricate(:review, task: task, user: current_user) }

          it { is_expected.to be_able_to(:read, review) }
          it { is_expected.not_to be_able_to(:update, review) }
          it { is_expected.to be_able_to(:approve, review) }
          it { is_expected.to be_able_to(:disapprove, review) }
        end

        context "when doesn't belong to them" do
          let(:review) { Fabricate(:review, task: task) }

          it { is_expected.to be_able_to(:read, review) }
          it { is_expected.not_to be_able_to(:update, review) }
          it { is_expected.not_to be_able_to(:destroy, review) }
          it { is_expected.to be_able_to(:approve, review) }
          it { is_expected.to be_able_to(:disapprove, review) }
        end

        context "when their review is pending" do
          context "and task is open" do
            let(:review) { Fabricate(:review, task: task, user: current_user) }

            it { is_expected.to be_able_to(:destroy, review) }
          end

          context "and task is closed" do
            let(:task) { Fabricate(:closed_task) }
            let(:review) { Fabricate(:review, task: task, user: current_user) }

            it { is_expected.not_to be_able_to(:destroy, review) }
          end
        end

        context "when already approved" do
          let(:review) do
            Fabricate(:approved_review, task: task, user: current_user)
          end

          it { is_expected.not_to be_able_to(:destroy, review) }
        end

        context "when already disapproved" do
          let(:review) do
            Fabricate(:disapproved_review, task: task, user: current_user)
          end

          it { is_expected.not_to be_able_to(:destroy, review) }
        end
      end
    end

    %i[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        context "when assigned to the task" do
          let(:review) do
            Fabricate.build(:review, task: task, user: current_user)
          end

          before { task.assignees << current_user }

          it { is_expected.to be_able_to(:create, review) }
        end

        context "when not assigned to the task" do
          let(:review) do
            Fabricate.build(:review, task: task, user: current_user)
          end

          it { is_expected.not_to be_able_to(:create, review) }
        end

        context "when belongs to them" do
          let(:review) { Fabricate(:review, task: task, user: current_user) }

          it { is_expected.to be_able_to(:read, review) }
          it { is_expected.not_to be_able_to(:update, review) }
          it { is_expected.to be_able_to(:destroy, review) }
          it { is_expected.not_to be_able_to(:approve, review) }
          it { is_expected.not_to be_able_to(:disapprove, review) }
        end

        context "when doesn't belong to them" do
          let(:review) { Fabricate(:review, task: task) }

          it { is_expected.to be_able_to(:read, review) }
          it { is_expected.not_to be_able_to(:update, review) }
          it { is_expected.not_to be_able_to(:destroy, review) }
          it { is_expected.not_to be_able_to(:approve, review) }
          it { is_expected.not_to be_able_to(:disapprove, review) }
        end
      end
    end
  end

  describe "Task model" do
    describe "for an admin" do
      let(:category) { Fabricate(:category) }
      let(:project) { Fabricate(:project, category: category) }
      let(:admin) { Fabricate(:user_admin) }

      subject(:ability) { Ability.new(admin) }

      context "when task category is visible" do
        context "and external" do
          context "while project is visible" do
            context "and external" do
              context "when belongs to them" do
                let(:task) { Fabricate(:task, project: project, user: admin) }

                it { is_expected.to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
              end

              context "when doesn't belong to them" do
                let(:task) { Fabricate(:task, project: project) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:project, category: category, internal: true)
              end

              context "when belongs to them" do
                let(:task) { Fabricate(:task, project: project, user: admin) }

                it { is_expected.to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
              end

              context "when doesn't belong to them" do
                let(:task) { Fabricate(:task, project: project) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:task) { Fabricate(:task, project: project, user: admin) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
              end

              context "when doesn't belong to them" do
                let(:task) { Fabricate(:task, project: project) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:project, category: category, visible: false,
                                    internal: true)
              end

              context "when belongs to them" do
                let(:task) { Fabricate(:task, project: project, user: admin) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
              end

              context "when doesn't belong to them" do
                let(:task) { Fabricate(:task, project: project) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
              end
            end
          end
        end
      end

      context "when task category is invisible" do
        context "and external" do
          let(:category) { Fabricate(:category, visible: false) }

          context "while project is visible" do
            context "and external" do
              context "when belongs to them" do
                let(:task) { Fabricate(:task, project: project, user: admin) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
              end

              context "when doesn't belong to them" do
                let(:task) { Fabricate(:task, project: project) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:project, category: category, internal: true)
              end

              context "when belongs to them" do
                let(:task) { Fabricate(:task, project: project, user: admin) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
              end

              context "when doesn't belong to them" do
                let(:task) { Fabricate(:task, project: project) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:task) { Fabricate(:task, project: project, user: admin) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
              end

              context "when doesn't belong to them" do
                let(:task) { Fabricate(:task, project: project) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:project, category: category, visible: false,
                                    internal: true)
              end

              context "when belongs to them" do
                let(:task) { Fabricate(:task, project: project, user: admin) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
              end

              context "when doesn't belong to them" do
                let(:task) { Fabricate(:task, project: project) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
              end
            end
          end
        end
      end
    end

    describe "for a reviewer" do
      let(:category) { Fabricate(:category) }
      let(:project) { Fabricate(:project, category: category) }
      let(:current_user) { Fabricate(:user_reviewer) }

      subject(:ability) { Ability.new(current_user) }

      context "when task category is visible" do
        context "and external" do
          context "while project is visible" do
            context "and external" do
              context "when belongs to them" do
                let(:task) do
                  Fabricate(:task, project: project, user: current_user)
                end

                it { is_expected.to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
              end

              context "when doesn't belong to them" do
                let(:task) { Fabricate(:task, project: project) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:project, category: category, internal: true)
              end

              context "when belongs to them" do
                let(:task) do
                  Fabricate(:task, project: project, user: current_user)
                end

                it { is_expected.to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
              end

              context "when doesn't belong to them" do
                let(:task) { Fabricate(:task, project: project) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:task) do
                  Fabricate(:task, project: project, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
              end

              context "when doesn't belong to them" do
                let(:task) { Fabricate(:task, project: project) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:project, category: category, visible: false,
                                    internal: true)
              end

              context "when belongs to them" do
                let(:task) do
                  Fabricate(:task, project: project, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
              end

              context "when doesn't belong to them" do
                let(:task) { Fabricate(:task, project: project) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
              end
            end
          end
        end
      end

      context "when task category is invisible" do
        context "and external" do
          let(:category) { Fabricate(:category, visible: false) }

          context "while project is visible" do
            context "and external" do
              context "when belongs to them" do
                let(:task) do
                  Fabricate(:task, project: project, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
              end

              context "when doesn't belong to them" do
                let(:task) { Fabricate(:task, project: project) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:project, category: category, internal: true)
              end

              context "when belongs to them" do
                let(:task) do
                  Fabricate(:task, project: project, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
              end

              context "when doesn't belong to them" do
                let(:task) { Fabricate(:task, project: project) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:task) do
                  Fabricate(:task, project: project, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
              end

              context "when doesn't belong to them" do
                let(:task) { Fabricate(:task, project: project) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:project, category: category, visible: false,
                                    internal: true)
              end

              context "when belongs to them" do
                let(:task) do
                  Fabricate(:task, project: project, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
              end

              context "when doesn't belong to them" do
                let(:task) { Fabricate(:task, project: project) }

                it { is_expected.not_to be_able_to(:create, task) }
                it { is_expected.to be_able_to(:read, task) }
                it { is_expected.not_to be_able_to(:update, task) }
                it { is_expected.not_to be_able_to(:destroy, task) }
                it { is_expected.to be_able_to(:assign, task) }
              end
            end
          end
        end
      end
    end

    %i[worker].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        let(:category) { Fabricate(:category) }
        let(:project) { Fabricate(:project, category: category) }

        subject(:ability) { Ability.new(current_user) }

        context "when category is visible" do
          context "and external" do
            context "while project is visible" do
              context "and external" do
                context "when belongs to them" do
                  let(:task) do
                    Fabricate(:task, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end

                context "when doesn't belong to them" do
                  let(:task) { Fabricate(:task, project: project) }

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, internal: true)
                end

                context "when belongs to them" do
                  let(:task) do
                    Fabricate(:task, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end

                context "when doesn't belong to them" do
                  let(:task) { Fabricate(:task, project: project) }

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end
              end
            end

            context "while project is invisible" do
              context "and external" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: false)
                end

                context "when belongs to them" do
                  let(:task) do
                    Fabricate(:task, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end

                context "when doesn't belong to them" do
                  let(:task) { Fabricate(:task, project: project) }

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: true)
                end

                context "when belongs to them" do
                  let(:task) do
                    Fabricate(:task, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end

                context "when doesn't belong to them" do
                  let(:task) { Fabricate(:task, project: project) }

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end
              end
            end
          end
        end

        context "when category is invisible" do
          context "and external" do
            let(:category) { Fabricate(:category, visible: false) }

            context "while project is visible" do
              context "and external" do
                context "when belongs to them" do
                  let(:task) do
                    Fabricate(:task, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end

                context "when doesn't belong to them" do
                  let(:task) { Fabricate(:task, project: project) }

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, internal: true)
                end

                context "when belongs to them" do
                  let(:task) do
                    Fabricate(:task, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end

                context "when doesn't belong to them" do
                  let(:task) { Fabricate(:task, project: project) }

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end
              end
            end

            context "while project is invisible" do
              context "and external" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: false)
                end

                context "when belongs to them" do
                  let(:task) do
                    Fabricate(:task, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end

                context "when doesn't belong to them" do
                  let(:task) { Fabricate(:task, project: project) }

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: true)
                end

                context "when belongs to them" do
                  let(:task) do
                    Fabricate(:task, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end

                context "when doesn't belong to them" do
                  let(:task) { Fabricate(:task, project: project) }

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end
              end
            end
          end

          context "and internal" do
            let(:category) do
              Fabricate(:category, visible: true, internal: true)
            end

            context "while project is visible" do
              context "and external" do
                context "when belongs to them" do
                  let(:task) do
                    Fabricate(:task, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end

                context "when doesn't belong to them" do
                  let(:task) { Fabricate(:task, project: project) }

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, internal: true)
                end

                context "when belongs to them" do
                  let(:task) do
                    Fabricate(:task, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end

                context "when doesn't belong to them" do
                  let(:task) { Fabricate(:task, project: project) }

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end
              end
            end

            context "while project is invisible" do
              context "and external" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: false)
                end

                context "when belongs to them" do
                  let(:task) do
                    Fabricate(:task, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end

                context "when doesn't belong to them" do
                  let(:task) { Fabricate(:task, project: project) }

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: true)
                end

                context "when belongs to them" do
                  let(:task) do
                    Fabricate(:task, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end

                context "when doesn't belong to them" do
                  let(:task) { Fabricate(:task, project: project) }

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end
              end
            end
          end
        end
      end
    end

    %i[reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        let(:category) { Fabricate(:category) }
        let(:project) { Fabricate(:project, category: category) }

        subject(:ability) { Ability.new(current_user) }

        context "when category is visible" do
          context "and external" do
            context "while project is visible" do
              context "and external" do
                context "when belongs to them" do
                  let(:task) do
                    Fabricate(:task, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end

                context "when doesn't belong to them" do
                  let(:task) { Fabricate(:task, project: project) }

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, internal: true)
                end

                context "when belongs to them" do
                  let(:task) do
                    Fabricate(:task, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end

                context "when doesn't belong to them" do
                  let(:task) { Fabricate(:task, project: project) }

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end
              end
            end

            context "while project is invisible" do
              context "and external" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: false)
                end

                context "when belongs to them" do
                  let(:task) do
                    Fabricate(:task, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end

                context "when doesn't belong to them" do
                  let(:task) { Fabricate(:task, project: project) }

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: true)
                end

                context "when belongs to them" do
                  let(:task) do
                    Fabricate(:task, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end

                context "when doesn't belong to them" do
                  let(:task) { Fabricate(:task, project: project) }

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end
              end
            end
          end
        end

        context "when category is invisible" do
          context "and external" do
            let(:category) { Fabricate(:category, visible: false) }

            context "while project is visible" do
              context "and external" do
                context "when belongs to them" do
                  let(:task) do
                    Fabricate(:task, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end

                context "when doesn't belong to them" do
                  let(:task) { Fabricate(:task, project: project) }

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, internal: true)
                end

                context "when belongs to them" do
                  let(:task) do
                    Fabricate(:task, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end

                context "when doesn't belong to them" do
                  let(:task) { Fabricate(:task, project: project) }

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end
              end
            end

            context "while project is invisible" do
              context "and external" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: false)
                end

                context "when belongs to them" do
                  let(:task) do
                    Fabricate(:task, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end

                context "when doesn't belong to them" do
                  let(:task) { Fabricate(:task, project: project) }

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: true)
                end

                context "when belongs to them" do
                  let(:task) do
                    Fabricate(:task, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end

                context "when doesn't belong to them" do
                  let(:task) { Fabricate(:task, project: project) }

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end
              end
            end
          end

          context "and internal" do
            let(:category) do
              Fabricate(:category, visible: true, internal: true)
            end

            context "while project is visible" do
              context "and external" do
                context "when belongs to them" do
                  let(:task) do
                    Fabricate(:task, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end

                context "when doesn't belong to them" do
                  let(:task) { Fabricate(:task, project: project) }

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, internal: true)
                end

                context "when belongs to them" do
                  let(:task) do
                    Fabricate(:task, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end

                context "when doesn't belong to them" do
                  let(:task) { Fabricate(:task, project: project) }

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end
              end
            end

            context "while project is invisible" do
              context "and external" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: false)
                end

                context "when belongs to them" do
                  let(:task) do
                    Fabricate(:task, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end

                context "when doesn't belong to them" do
                  let(:task) { Fabricate(:task, project: project) }

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: true)
                end

                context "when belongs to them" do
                  let(:task) do
                    Fabricate(:task, project: project, user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end

                context "when doesn't belong to them" do
                  let(:task) { Fabricate(:task, project: project) }

                  it { is_expected.not_to be_able_to(:create, task) }
                  it { is_expected.not_to be_able_to(:read, task) }
                  it { is_expected.not_to be_able_to(:update, task) }
                  it { is_expected.not_to be_able_to(:destroy, task) }
                  it { is_expected.not_to be_able_to(:assign, task) }
                end
              end
            end
          end
        end
      end
    end
  end

  describe "TaskComment model" do
    describe "for an admin" do
      let(:task) { Fabricate(:task, project: project) }
      let(:admin) { Fabricate(:user_admin) }
      subject(:ability) { Ability.new(admin) }

      context "when category is visible" do
        context "and external" do
          let(:category) { Fabricate(:category) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: admin)
                end

                it { is_expected.to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: admin)
                end

                it { is_expected.to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:invisible_project, category: category)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: admin)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:internal_project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: admin)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end
            end
          end
        end

        context "and internal" do
          let(:category) { Fabricate(:internal_category) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: admin)
                end

                it { is_expected.to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: admin)
                end

                it { is_expected.to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:invisible_project, category: category)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: admin)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:internal_project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: admin)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end
            end
          end
        end
      end

      context "when category is invisible" do
        context "and external" do
          let(:category) { Fabricate(:invisible_category) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: admin)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: admin)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end
            end
          end
        end

        context "and internal" do
          let(:category) { Fabricate(:invisible_category, internal: true) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: admin)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: admin)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:invisible_project, category: category)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: admin)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:internal_project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: admin)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.to be_able_to(:destroy, task_comment) }
              end
            end
          end
        end
      end
    end

    describe "for a reviewer" do
      let(:task) { Fabricate(:task, project: project) }
      let(:current_user) { Fabricate(:user_reviewer) }
      subject(:ability) { Ability.new(current_user) }

      context "when category is visible" do
        context "and external" do
          let(:category) { Fabricate(:category) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:invisible_project, category: category)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:internal_project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end
        end

        context "and internal" do
          let(:category) { Fabricate(:internal_category) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:invisible_project, category: category)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:internal_project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end
        end
      end

      context "when category is invisible" do
        context "and external" do
          let(:category) { Fabricate(:invisible_category) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end
        end

        context "and internal" do
          let(:category) { Fabricate(:invisible_category, internal: true) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:invisible_project, category: category)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:internal_project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end
        end
      end
    end

    describe "for a worker" do
      let(:task) { Fabricate(:task, project: project) }
      let(:current_user) { Fabricate(:user_worker) }
      subject(:ability) { Ability.new(current_user) }

      context "when category is visible" do
        context "and external" do
          let(:category) { Fabricate(:category) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:invisible_project, category: category)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:internal_project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end
        end

        context "and internal" do
          let(:category) { Fabricate(:internal_category) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:invisible_project, category: category)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:internal_project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end
        end
      end

      context "when category is invisible" do
        context "and external" do
          let(:category) { Fabricate(:invisible_category) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end
        end

        context "and internal" do
          let(:category) { Fabricate(:invisible_category, internal: true) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:invisible_project, category: category)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:internal_project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end
        end
      end
    end

    describe "for a reporter" do
      let(:task) { Fabricate(:task, project: project) }
      let(:current_user) { Fabricate(:user_reporter) }
      subject(:ability) { Ability.new(current_user) }

      context "when category is visible" do
        context "and external" do
          let(:category) { Fabricate(:category) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:invisible_project, category: category)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:internal_project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end
        end

        context "and internal" do
          let(:category) { Fabricate(:internal_category) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:invisible_project, category: category)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:internal_project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end
        end
      end

      context "when category is invisible" do
        context "and external" do
          let(:category) { Fabricate(:invisible_category) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end
        end

        context "and internal" do
          let(:category) { Fabricate(:invisible_category, internal: true) }

          context "while project is visible" do
            context "and external" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) { Fabricate(:internal_project, category: category) }

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end

          context "while project is invisible" do
            context "and external" do
              let(:project) do
                Fabricate(:invisible_project, category: category)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end

            context "and internal" do
              let(:project) do
                Fabricate(:internal_project, category: category, visible: false)
              end

              context "when belongs to them" do
                let(:task_comment) do
                  Fabricate(:task_comment, task: task, user: current_user)
                end

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end

              context "when doesn't belong to them" do
                let(:task_comment) { Fabricate(:task_comment, task: task) }

                it { is_expected.not_to be_able_to(:create, task_comment) }
                it { is_expected.not_to be_able_to(:read, task_comment) }
                it { is_expected.not_to be_able_to(:update, task_comment) }
                it { is_expected.not_to be_able_to(:destroy, task_comment) }
              end
            end
          end
        end
      end
    end
  end

  describe "TaskClosure model" do
    %i[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        subject(:ability) { Ability.new(current_user) }

        context "when their closure" do
          let(:task_closure) { Fabricate(:task_closure, user: current_user) }

          it { is_expected.to be_able_to(:create, task_closure) }
          it { is_expected.to be_able_to(:read, task_closure) }
          it { is_expected.not_to be_able_to(:update, task_closure) }
          it { is_expected.to be_able_to(:destroy, task_closure) }
        end

        context "when someone else's closure" do
          let(:task_closure) { Fabricate(:task_closure) }

          it { is_expected.not_to be_able_to(:create, task_closure) }
          it { is_expected.to be_able_to(:read, task_closure) }
          it { is_expected.not_to be_able_to(:update, task_closure) }
          it { is_expected.to be_able_to(:destroy, task_closure) }
        end
      end
    end

    %i[reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        subject(:ability) { Ability.new(current_user) }

        context "when their task and closure" do
          let(:task) { Fabricate(:task, user: current_user) }
          let(:task_closure) do
            Fabricate(:task_closure, task: task, user: current_user)
          end

          it { is_expected.to be_able_to(:create, task_closure) }
          it { is_expected.to be_able_to(:read, task_closure) }
          it { is_expected.not_to be_able_to(:update, task_closure) }
          it { is_expected.not_to be_able_to(:destroy, task_closure) }
        end

        context "when their closure, someone else's task" do
          let(:task_closure) { Fabricate(:task_closure, user: current_user) }

          it { is_expected.not_to be_able_to(:create, task_closure) }
          it { is_expected.to be_able_to(:read, task_closure) }
          it { is_expected.not_to be_able_to(:update, task_closure) }
          it { is_expected.not_to be_able_to(:destroy, task_closure) }
        end

        context "when their task, someone else's closure" do
          let(:task) { Fabricate(:task, user: current_user) }
          let(:task_closure) { Fabricate(:task_closure, task: task) }

          it { is_expected.not_to be_able_to(:create, task_closure) }
          it { is_expected.to be_able_to(:read, task_closure) }
          it { is_expected.not_to be_able_to(:update, task_closure) }
          it { is_expected.not_to be_able_to(:destroy, task_closure) }
        end

        context "when someone else's task and closure" do
          let(:task_closure) { Fabricate(:task_closure) }

          it { is_expected.not_to be_able_to(:create, task_closure) }
          it { is_expected.to be_able_to(:read, task_closure) }
          it { is_expected.not_to be_able_to(:update, task_closure) }
          it { is_expected.not_to be_able_to(:destroy, task_closure) }
        end
      end
    end

    %i[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        let(:task) { Fabricate(:task, user: current_user) }
        let(:task_closure) do
          Fabricate(:task_closure, task: task, user: current_user)
        end

        subject(:ability) { Ability.new(current_user) }

        it { is_expected.not_to be_able_to(:create, task_closure) }
        it { is_expected.to be_able_to(:read, task_closure) }
        it { is_expected.not_to be_able_to(:update, task_closure) }
        it { is_expected.not_to be_able_to(:destroy, task_closure) }
      end
    end
  end

  describe "TaskConnection model" do
    %i[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        subject(:ability) { Ability.new(current_user) }

        context "when their connection" do
          let(:task_connection) do
            Fabricate(:task_connection, user: current_user)
          end

          it { is_expected.to be_able_to(:create, task_connection) }
          it { is_expected.to be_able_to(:read, task_connection) }
          it { is_expected.to be_able_to(:update, task_connection) }
          it { is_expected.to be_able_to(:destroy, task_connection) }
        end

        context "when someone else's connection" do
          let(:task_connection) { Fabricate(:task_connection) }

          it { is_expected.not_to be_able_to(:create, task_connection) }
          it { is_expected.to be_able_to(:read, task_connection) }
          it { is_expected.not_to be_able_to(:update, task_connection) }
          it { is_expected.to be_able_to(:destroy, task_connection) }
        end
      end
    end

    %i[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        let(:task_connection) do
          Fabricate(:task_connection, user: current_user)
        end

        subject(:ability) { Ability.new(current_user) }

        it { is_expected.not_to be_able_to(:create, task_connection) }
        it { is_expected.to be_able_to(:read, task_connection) }
        it { is_expected.not_to be_able_to(:update, task_connection) }
        it { is_expected.not_to be_able_to(:destroy, task_connection) }
      end
    end
  end

  describe "TaskReopening model" do
    %i[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        subject(:ability) { Ability.new(current_user) }

        context "when their closure" do
          let(:task_reopening) do
            Fabricate(:task_reopening, user: current_user)
          end

          it { is_expected.to be_able_to(:create, task_reopening) }
          it { is_expected.to be_able_to(:read, task_reopening) }
          it { is_expected.not_to be_able_to(:update, task_reopening) }
          it { is_expected.to be_able_to(:destroy, task_reopening) }
        end

        context "when someone else's reopening" do
          let(:task_reopening) { Fabricate(:task_reopening) }

          it { is_expected.not_to be_able_to(:create, task_reopening) }
          it { is_expected.to be_able_to(:read, task_reopening) }
          it { is_expected.not_to be_able_to(:update, task_reopening) }
          it { is_expected.to be_able_to(:destroy, task_reopening) }
        end
      end
    end

    %i[reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        subject(:ability) { Ability.new(current_user) }

        context "when their reopening" do
          let(:task_reopening) do
            Fabricate(:task_reopening, user: current_user)
          end

          it { is_expected.to be_able_to(:create, task_reopening) }
          it { is_expected.to be_able_to(:read, task_reopening) }
          it { is_expected.not_to be_able_to(:update, task_reopening) }
          it { is_expected.not_to be_able_to(:destroy, task_reopening) }
        end

        context "when someone else's reopening" do
          let(:task_reopening) { Fabricate(:task_reopening) }

          it { is_expected.not_to be_able_to(:create, task_reopening) }
          it { is_expected.to be_able_to(:read, task_reopening) }
          it { is_expected.not_to be_able_to(:update, task_reopening) }
          it { is_expected.not_to be_able_to(:destroy, task_reopening) }
        end
      end
    end

    %i[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        let(:task_reopening) do
          Fabricate(:task_reopening, user: current_user)
        end

        subject(:ability) { Ability.new(current_user) }

        it { is_expected.not_to be_able_to(:create, task_reopening) }
        it { is_expected.to be_able_to(:read, task_reopening) }
        it { is_expected.not_to be_able_to(:update, task_reopening) }
        it { is_expected.not_to be_able_to(:destroy, task_reopening) }
      end
    end
  end

  describe "TaskType model" do
    let(:task_type) { Fabricate(:task_type) }

    %i[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        it { is_expected.to be_able_to(:create, task_type) }
        it { is_expected.to be_able_to(:read, task_type) }
        it { is_expected.to be_able_to(:update, task_type) }
        it { is_expected.to be_able_to(:destroy, task_type) }
      end
    end

    %i[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        it { is_expected.not_to be_able_to(:create, task_type) }
        it { is_expected.not_to be_able_to(:read, task_type) }
        it { is_expected.not_to be_able_to(:update, task_type) }
        it { is_expected.not_to be_able_to(:destroy, task_type) }
      end
    end
  end

  describe "TaskSubscription model" do
    describe "for an admin" do
      let(:admin) { Fabricate(:user_admin) }
      subject(:ability) { Ability.new(admin) }

      context "when belongs to them" do
        let(:task_subscription) { Fabricate(:task_subscription, user: admin) }

        it { is_expected.to be_able_to(:create, task_subscription) }
        it { is_expected.to be_able_to(:read, task_subscription) }
        it { is_expected.to be_able_to(:update, task_subscription) }
        it { is_expected.to be_able_to(:destroy, task_subscription) }
      end

      context "when doesn't belong to them" do
        let(:task_subscription) { Fabricate(:task_subscription) }

        it { is_expected.not_to be_able_to(:create, task_subscription) }
        it { is_expected.not_to be_able_to(:read, task_subscription) }
        it { is_expected.not_to be_able_to(:update, task_subscription) }
        it { is_expected.not_to be_able_to(:destroy, task_subscription) }
      end
    end

    %i[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        context "when belongs to them" do
          let(:task_subscription) do
            Fabricate(:task_subscription, user: current_user)
          end

          it { is_expected.to be_able_to(:create, task_subscription) }
          it { is_expected.to be_able_to(:read, task_subscription) }
          it { is_expected.to be_able_to(:update, task_subscription) }
          it { is_expected.to be_able_to(:destroy, task_subscription) }
        end

        context "when doesn't belong to them" do
          let(:task_subscription) { Fabricate(:task_subscription) }

          it { is_expected.not_to be_able_to(:create, task_subscription) }
          it { is_expected.not_to be_able_to(:read, task_subscription) }
          it { is_expected.not_to be_able_to(:update, task_subscription) }
          it { is_expected.not_to be_able_to(:destroy, task_subscription) }
        end
      end
    end
  end

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
