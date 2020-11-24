# frozen_string_literal: true

require "rails_helper"
require "cancan/matchers"

RSpec.describe Ability do
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
    %w[admin reviewer worker].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        context "when project is totally visible" do
          let(:category) { Fabricate(:category) }
          let(:project) { Fabricate(:project, category: category) }

          context "when belongs to them" do
            let(:subscription) do
              Fabricate(:project_issues_subscription, project: project,
                                                      user: current_user)
            end

            it { is_expected.to be_able_to(:create, subscription) }
            it { is_expected.to be_able_to(:read, subscription) }
            it { is_expected.to be_able_to(:update, subscription) }
            it { is_expected.to be_able_to(:destroy, subscription) }
          end

          context "when doesn't belong to them" do
            let(:subscription) do
              Fabricate(:project_issues_subscription, project: project)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end
        end

        context "when project is internal" do
          let(:category) { Fabricate(:category) }
          let(:project) { Fabricate(:internal_project, category: category) }

          context "when belongs to them" do
            let(:subscription) do
              Fabricate(:project_issues_subscription, project: project,
                                                      user: current_user)
            end

            it { is_expected.to be_able_to(:create, subscription) }
            it { is_expected.to be_able_to(:read, subscription) }
            it { is_expected.to be_able_to(:update, subscription) }
            it { is_expected.to be_able_to(:destroy, subscription) }
          end

          context "when doesn't belong to them" do
            let(:subscription) do
              Fabricate(:project_issues_subscription, project: project)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end
        end

        context "when project is invisible" do
          let(:category) { Fabricate(:category) }
          let(:project) { Fabricate(:invisible_project, category: category) }

          context "when belongs to them" do
            let(:subscription) do
              Fabricate(:project_issues_subscription, project: project,
                                                      user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end

          context "when doesn't belong to them" do
            let(:subscription) do
              Fabricate(:project_issues_subscription, project: project)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end
        end

        context "when category is internal" do
          let(:category) { Fabricate(:internal_category) }
          let(:project) { Fabricate(:project, category: category) }

          context "when belongs to them" do
            let(:subscription) do
              Fabricate(:project_issues_subscription, project: project,
                                                      user: current_user)
            end

            it { is_expected.to be_able_to(:create, subscription) }
            it { is_expected.to be_able_to(:read, subscription) }
            it { is_expected.to be_able_to(:update, subscription) }
            it { is_expected.to be_able_to(:destroy, subscription) }
          end

          context "when doesn't belong to them" do
            let(:subscription) do
              Fabricate(:project_issues_subscription, project: project)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end
        end

        context "when category is invisible" do
          let(:category) { Fabricate(:invisible_category) }
          let(:project) { Fabricate(:project, category: category) }

          context "when belongs to them" do
            let(:subscription) do
              Fabricate(:project_issues_subscription, project: project,
                                                      user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end

          context "when doesn't belong to them" do
            let(:subscription) do
              Fabricate(:project_issues_subscription, project: project)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end
        end
      end
    end

    %w[reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        context "when project is totally visible" do
          let(:category) { Fabricate(:category) }
          let(:project) { Fabricate(:project, category: category) }

          context "when belongs to them" do
            let(:subscription) do
              Fabricate(:project_issues_subscription, project: project,
                                                      user: current_user)
            end

            it { is_expected.to be_able_to(:create, subscription) }
            it { is_expected.to be_able_to(:read, subscription) }
            it { is_expected.to be_able_to(:update, subscription) }
            it { is_expected.to be_able_to(:destroy, subscription) }
          end

          context "when doesn't belong to them" do
            let(:subscription) do
              Fabricate(:project_issues_subscription, project: project)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end
        end

        context "when project is internal" do
          let(:category) { Fabricate(:category) }
          let(:project) { Fabricate(:internal_project, category: category) }

          context "when belongs to them" do
            let(:subscription) do
              Fabricate(:project_issues_subscription, project: project,
                                                      user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end

          context "when doesn't belong to them" do
            let(:subscription) do
              Fabricate(:project_issues_subscription, project: project)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end
        end

        context "when project is invisible" do
          let(:category) { Fabricate(:category) }
          let(:project) { Fabricate(:invisible_project, category: category) }

          context "when belongs to them" do
            let(:subscription) do
              Fabricate(:project_issues_subscription, project: project,
                                                      user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end

          context "when doesn't belong to them" do
            let(:subscription) do
              Fabricate(:project_issues_subscription, project: project)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end
        end

        context "when category is internal" do
          let(:category) { Fabricate(:internal_category) }
          let(:project) { Fabricate(:project, category: category) }

          context "when belongs to them" do
            let(:subscription) do
              Fabricate(:project_issues_subscription, project: project,
                                                      user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end

          context "when doesn't belong to them" do
            let(:subscription) do
              Fabricate(:project_issues_subscription, project: project)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end
        end

        context "when category is invisible" do
          let(:category) { Fabricate(:invisible_category) }
          let(:project) { Fabricate(:project, category: category) }

          context "when belongs to them" do
            let(:subscription) do
              Fabricate(:project_issues_subscription, project: project,
                                                      user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end

          context "when doesn't belong to them" do
            let(:subscription) do
              Fabricate(:project_issues_subscription, project: project)
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

  describe "ProjectTasksSubscription model" do
    %w[admin reviewer worker].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        context "when project is totally visible" do
          let(:category) { Fabricate(:category) }
          let(:project) { Fabricate(:project, category: category) }

          context "when belongs to them" do
            let(:subscription) do
              Fabricate(:project_tasks_subscription, project: project,
                                                     user: current_user)
            end

            it { is_expected.to be_able_to(:create, subscription) }
            it { is_expected.to be_able_to(:read, subscription) }
            it { is_expected.to be_able_to(:update, subscription) }
            it { is_expected.to be_able_to(:destroy, subscription) }
          end

          context "when doesn't belong to them" do
            let(:subscription) do
              Fabricate(:project_tasks_subscription, project: project)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end
        end

        context "when project is internal" do
          let(:category) { Fabricate(:category) }
          let(:project) { Fabricate(:internal_project, category: category) }

          context "when belongs to them" do
            let(:subscription) do
              Fabricate(:project_tasks_subscription, project: project,
                                                     user: current_user)
            end

            it { is_expected.to be_able_to(:create, subscription) }
            it { is_expected.to be_able_to(:read, subscription) }
            it { is_expected.to be_able_to(:update, subscription) }
            it { is_expected.to be_able_to(:destroy, subscription) }
          end

          context "when doesn't belong to them" do
            let(:subscription) do
              Fabricate(:project_tasks_subscription, project: project)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end
        end

        context "when project is invisible" do
          let(:category) { Fabricate(:category) }
          let(:project) { Fabricate(:invisible_project, category: category) }

          context "when belongs to them" do
            let(:subscription) do
              Fabricate(:project_tasks_subscription, project: project,
                                                     user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end

          context "when doesn't belong to them" do
            let(:subscription) do
              Fabricate(:project_tasks_subscription, project: project)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end
        end

        context "when category is internal" do
          let(:category) { Fabricate(:internal_category) }
          let(:project) { Fabricate(:project, category: category) }

          context "when belongs to them" do
            let(:subscription) do
              Fabricate(:project_tasks_subscription, project: project,
                                                     user: current_user)
            end

            it { is_expected.to be_able_to(:create, subscription) }
            it { is_expected.to be_able_to(:read, subscription) }
            it { is_expected.to be_able_to(:update, subscription) }
            it { is_expected.to be_able_to(:destroy, subscription) }
          end

          context "when doesn't belong to them" do
            let(:subscription) do
              Fabricate(:project_tasks_subscription, project: project)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end
        end

        context "when category is invisible" do
          let(:category) { Fabricate(:invisible_category) }
          let(:project) { Fabricate(:project, category: category) }

          context "when belongs to them" do
            let(:subscription) do
              Fabricate(:project_tasks_subscription, project: project,
                                                     user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end

          context "when doesn't belong to them" do
            let(:subscription) do
              Fabricate(:project_tasks_subscription, project: project)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end
        end
      end
    end

    %w[reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        context "when project is totally visible" do
          let(:category) { Fabricate(:category) }
          let(:project) { Fabricate(:project, category: category) }

          context "when belongs to them" do
            let(:subscription) do
              Fabricate(:project_tasks_subscription, project: project,
                                                     user: current_user)
            end

            it { is_expected.to be_able_to(:create, subscription) }
            it { is_expected.to be_able_to(:read, subscription) }
            it { is_expected.to be_able_to(:update, subscription) }
            it { is_expected.to be_able_to(:destroy, subscription) }
          end

          context "when doesn't belong to them" do
            let(:subscription) do
              Fabricate(:project_tasks_subscription, project: project)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end
        end

        context "when project is internal" do
          let(:category) { Fabricate(:category) }
          let(:project) { Fabricate(:internal_project, category: category) }

          context "when belongs to them" do
            let(:subscription) do
              Fabricate(:project_tasks_subscription, project: project,
                                                     user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end

          context "when doesn't belong to them" do
            let(:subscription) do
              Fabricate(:project_tasks_subscription, project: project)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end
        end

        context "when project is invisible" do
          let(:category) { Fabricate(:category) }
          let(:project) { Fabricate(:invisible_project, category: category) }

          context "when belongs to them" do
            let(:subscription) do
              Fabricate(:project_tasks_subscription, project: project,
                                                     user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end

          context "when doesn't belong to them" do
            let(:subscription) do
              Fabricate(:project_tasks_subscription, project: project)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end
        end

        context "when category is internal" do
          let(:category) { Fabricate(:internal_category) }
          let(:project) { Fabricate(:project, category: category) }

          context "when belongs to them" do
            let(:subscription) do
              Fabricate(:project_tasks_subscription, project: project,
                                                     user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end

          context "when doesn't belong to them" do
            let(:subscription) do
              Fabricate(:project_tasks_subscription, project: project)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end
        end

        context "when category is invisible" do
          let(:category) { Fabricate(:invisible_category) }
          let(:project) { Fabricate(:project, category: category) }

          context "when belongs to them" do
            let(:subscription) do
              Fabricate(:project_tasks_subscription, project: project,
                                                     user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, subscription) }
            it { is_expected.not_to be_able_to(:read, subscription) }
            it { is_expected.not_to be_able_to(:update, subscription) }
            it { is_expected.not_to be_able_to(:destroy, subscription) }
          end

          context "when doesn't belong to them" do
            let(:subscription) do
              Fabricate(:project_tasks_subscription, project: project)
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
