# frozen_string_literal: true

require "rails_helper"
require "cancan/matchers"

RSpec.describe Ability do
  # TODO: when task_search_result

  describe "SearchResult model" do
    context "when class_name is 'Issue'" do
      describe "for an admin" do
        let(:category) { Fabricate(:category) }
        let(:project) { Fabricate(:project, category: category) }
        let(:admin) { Fabricate(:user_admin) }

        subject(:ability) { Ability.new(admin) }

        context "when search_result category is visible" do
          context "and external" do
            context "while project is visible" do
              context "and external" do
                context "when belongs to them" do
                  let(:search_result) do
                    Fabricate.build(:issue_search_result, project: project,
                                                          user: admin)
                  end

                  it { is_expected.to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.to be_able_to(:update, search_result) }
                  it { is_expected.to be_able_to(:destroy, search_result) }
                end

                context "when doesn't belong to them" do
                  let(:search_result) do
                    Fabricate.build(:issue_search_result, project: project)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.to be_able_to(:update, search_result) }
                  it { is_expected.to be_able_to(:destroy, search_result) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, internal: true)
                end

                context "when belongs to them" do
                  let(:search_result) do
                    Fabricate.build(:issue_search_result, project: project,
                                                          user: admin)
                  end

                  it { is_expected.to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.to be_able_to(:update, search_result) }
                  it { is_expected.to be_able_to(:destroy, search_result) }
                end

                context "when doesn't belong to them" do
                  let(:search_result) do
                    Fabricate.build(:issue_search_result, project: project)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.to be_able_to(:update, search_result) }
                  it { is_expected.to be_able_to(:destroy, search_result) }
                end
              end
            end

            context "while project is invisible" do
              context "and external" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false)
                end

                context "when belongs to them" do
                  let(:search_result) do
                    Fabricate.build(:issue_search_result, project: project,
                                                          user: admin)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.to be_able_to(:update, search_result) }
                  it { is_expected.to be_able_to(:destroy, search_result) }
                end

                context "when doesn't belong to them" do
                  let(:search_result) do
                    Fabricate.build(:issue_search_result, project: project)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.to be_able_to(:update, search_result) }
                  it { is_expected.to be_able_to(:destroy, search_result) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: true)
                end

                context "when belongs to them" do
                  let(:search_result) do
                    Fabricate.build(:issue_search_result, project: project,
                                                          user: admin)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.to be_able_to(:update, search_result) }
                  it { is_expected.to be_able_to(:destroy, search_result) }
                end

                context "when doesn't belong to them" do
                  let(:search_result) do
                    Fabricate.build(:issue_search_result, project: project)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.to be_able_to(:update, search_result) }
                  it { is_expected.to be_able_to(:destroy, search_result) }
                end
              end
            end

            context "while the search_result is closed" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:search_result) do
                  Fabricate.build(:closed_issue_search_result, project: project,
                                                               user: admin)
                end

                it { is_expected.to be_able_to(:create, search_result) }
                it { is_expected.to be_able_to(:read, search_result) }
                it { is_expected.to be_able_to(:update, search_result) }
                it { is_expected.to be_able_to(:destroy, search_result) }
              end

              context "when doesn't belong to them" do
                let(:search_result) do
                  Fabricate.build(:closed_issue_search_result, project: project)
                end

                it { is_expected.not_to be_able_to(:create, search_result) }
                it { is_expected.to be_able_to(:read, search_result) }
                it { is_expected.to be_able_to(:update, search_result) }
                it { is_expected.to be_able_to(:destroy, search_result) }
              end
            end
          end
        end

        context "when search_result category is invisible" do
          context "and external" do
            let(:category) { Fabricate(:category, visible: false) }

            context "while project is visible" do
              context "and external" do
                context "when belongs to them" do
                  let(:search_result) do
                    Fabricate.build(:issue_search_result, project: project,
                                                          user: admin)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.to be_able_to(:update, search_result) }
                  it { is_expected.to be_able_to(:destroy, search_result) }
                end

                context "when doesn't belong to them" do
                  let(:search_result) do
                    Fabricate.build(:issue_search_result, project: project)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.to be_able_to(:update, search_result) }
                  it { is_expected.to be_able_to(:destroy, search_result) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, internal: true)
                end

                context "when belongs to them" do
                  let(:search_result) do
                    Fabricate.build(:issue_search_result, project: project,
                                                          user: admin)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.to be_able_to(:update, search_result) }
                  it { is_expected.to be_able_to(:destroy, search_result) }
                end

                context "when doesn't belong to them" do
                  let(:search_result) do
                    Fabricate.build(:issue_search_result, project: project)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.to be_able_to(:update, search_result) }
                  it { is_expected.to be_able_to(:destroy, search_result) }
                end
              end
            end

            context "while project is invisible" do
              context "and external" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false)
                end

                context "when belongs to them" do
                  let(:search_result) do
                    Fabricate.build(:issue_search_result, project: project,
                                                          user: admin)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.to be_able_to(:update, search_result) }
                  it { is_expected.to be_able_to(:destroy, search_result) }
                end

                context "when doesn't belong to them" do
                  let(:search_result) do
                    Fabricate.build(:issue_search_result, project: project)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.to be_able_to(:update, search_result) }
                  it { is_expected.to be_able_to(:destroy, search_result) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: true)
                end

                context "when belongs to them" do
                  let(:search_result) do
                    Fabricate.build(:issue_search_result, project: project,
                                                          user: admin)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.to be_able_to(:update, search_result) }
                  it { is_expected.to be_able_to(:destroy, search_result) }
                end

                context "when doesn't belong to them" do
                  let(:search_result) do
                    Fabricate.build(:issue_search_result, project: project)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.to be_able_to(:update, search_result) }
                  it { is_expected.to be_able_to(:destroy, search_result) }
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

        context "when search_result category is visible" do
          context "and external" do
            context "while project is visible" do
              context "and external" do
                context "when belongs to them" do
                  let(:search_result) do
                    Fabricate.build(:issue_search_result, project: project,
                                                          user: current_user)
                  end

                  it { is_expected.to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.to be_able_to(:update, search_result) }
                  it { is_expected.not_to be_able_to(:destroy, search_result) }
                end

                context "when doesn't belong to them" do
                  let(:search_result) do
                    Fabricate.build(:issue_search_result, project: project)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.not_to be_able_to(:update, search_result) }
                  it { is_expected.not_to be_able_to(:destroy, search_result) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, internal: true)
                end

                context "when belongs to them" do
                  let(:search_result) do
                    Fabricate.build(:issue_search_result, project: project,
                                                          user: current_user)
                  end

                  it { is_expected.to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.to be_able_to(:update, search_result) }
                  it { is_expected.not_to be_able_to(:destroy, search_result) }
                end

                context "when doesn't belong to them" do
                  let(:search_result) do
                    Fabricate.build(:issue_search_result, project: project)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.not_to be_able_to(:update, search_result) }
                  it { is_expected.not_to be_able_to(:destroy, search_result) }
                end
              end
            end

            context "while project is invisible" do
              context "and external" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false)
                end

                context "when belongs to them" do
                  let(:search_result) do
                    Fabricate.build(:issue_search_result, project: project,
                                                          user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.not_to be_able_to(:update, search_result) }
                  it { is_expected.not_to be_able_to(:destroy, search_result) }
                end

                context "when doesn't belong to them" do
                  let(:search_result) do
                    Fabricate.build(:issue_search_result, project: project)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.not_to be_able_to(:update, search_result) }
                  it { is_expected.not_to be_able_to(:destroy, search_result) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: true)
                end

                context "when belongs to them" do
                  let(:search_result) do
                    Fabricate.build(:issue_search_result, project: project,
                                                          user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.not_to be_able_to(:update, search_result) }
                  it { is_expected.not_to be_able_to(:destroy, search_result) }
                end

                context "when doesn't belong to them" do
                  let(:search_result) do
                    Fabricate.build(:issue_search_result, project: project)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.not_to be_able_to(:update, search_result) }
                  it { is_expected.not_to be_able_to(:destroy, search_result) }
                end
              end
            end

            context "while search_result is closed" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:search_result) do
                  Fabricate.build(:closed_issue_search_result,
                                  project: project, user: current_user)
                end

                it { is_expected.to be_able_to(:create, search_result) }
                it { is_expected.to be_able_to(:read, search_result) }
                it { is_expected.to be_able_to(:update, search_result) }
                it { is_expected.not_to be_able_to(:destroy, search_result) }
              end

              context "when doesn't belong to them" do
                let(:search_result) do
                  Fabricate.build(:closed_issue_search_result, project: project)
                end

                it { is_expected.not_to be_able_to(:create, search_result) }
                it { is_expected.to be_able_to(:read, search_result) }
                it { is_expected.not_to be_able_to(:update, search_result) }
                it { is_expected.not_to be_able_to(:destroy, search_result) }
              end
            end
          end
        end

        context "when search_result category is invisible" do
          context "and external" do
            let(:category) { Fabricate(:category, visible: false) }

            context "while project is visible" do
              context "and external" do
                context "when belongs to them" do
                  let(:search_result) do
                    Fabricate.build(:issue_search_result, project: project,
                                                          user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.not_to be_able_to(:update, search_result) }
                  it { is_expected.not_to be_able_to(:destroy, search_result) }
                end

                context "when doesn't belong to them" do
                  let(:search_result) do
                    Fabricate.build(:issue_search_result, project: project)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.not_to be_able_to(:update, search_result) }
                  it { is_expected.not_to be_able_to(:destroy, search_result) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, internal: true)
                end

                context "when belongs to them" do
                  let(:search_result) do
                    Fabricate.build(:issue_search_result, project: project,
                                                          user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.not_to be_able_to(:update, search_result) }
                  it { is_expected.not_to be_able_to(:destroy, search_result) }
                end

                context "when doesn't belong to them" do
                  let(:search_result) do
                    Fabricate.build(:issue_search_result, project: project)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.not_to be_able_to(:update, search_result) }
                  it { is_expected.not_to be_able_to(:destroy, search_result) }
                end
              end
            end

            context "while project is invisible" do
              context "and external" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false)
                end

                context "when belongs to them" do
                  let(:search_result) do
                    Fabricate.build(:issue_search_result, project: project,
                                                          user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.not_to be_able_to(:update, search_result) }
                  it { is_expected.not_to be_able_to(:destroy, search_result) }
                end

                context "when doesn't belong to them" do
                  let(:search_result) do
                    Fabricate.build(:issue_search_result, project: project)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.not_to be_able_to(:update, search_result) }
                  it { is_expected.not_to be_able_to(:destroy, search_result) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: true)
                end

                context "when belongs to them" do
                  let(:search_result) do
                    Fabricate.build(:issue_search_result, project: project,
                                                          user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.not_to be_able_to(:update, search_result) }
                  it { is_expected.not_to be_able_to(:destroy, search_result) }
                end

                context "when doesn't belong to them" do
                  let(:search_result) do
                    Fabricate.build(:issue_search_result, project: project)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.not_to be_able_to(:update, search_result) }
                  it { is_expected.not_to be_able_to(:destroy, search_result) }
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
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project,
                                                            user: current_user)
                    end

                    it { is_expected.to be_able_to(:create, search_result) }
                    it { is_expected.to be_able_to(:read, search_result) }
                    it { is_expected.to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end
                end

                context "and internal" do
                  let(:project) do
                    Fabricate(:project, category: category, internal: true)
                  end

                  context "when belongs to them" do
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project,
                                                            user: current_user)
                    end

                    it { is_expected.to be_able_to(:create, search_result) }
                    it { is_expected.to be_able_to(:read, search_result) }
                    it { is_expected.to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
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
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project,
                                                            user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end
                end

                context "and internal" do
                  let(:project) do
                    Fabricate(:project, category: category, visible: false,
                                        internal: true)
                  end

                  context "when belongs to them" do
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project,
                                                            user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end
                end
              end

              context "while the search_result is closed" do
                let(:project) { Fabricate(:project, category: category) }

                context "when belongs to them" do
                  let(:search_result) do
                    Fabricate.build(:closed_issue_search_result,
                                    project: project, user: current_user)
                  end

                  it { is_expected.to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.to be_able_to(:update, search_result) }
                  it { is_expected.not_to be_able_to(:destroy, search_result) }
                end

                context "when doesn't belong to them" do
                  let(:search_result) do
                    Fabricate.build(:closed_issue_search_result,
                                    project: project)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.not_to be_able_to(:update, search_result) }
                  it { is_expected.not_to be_able_to(:destroy, search_result) }
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
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project,
                                                            user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end
                end

                context "and internal" do
                  let(:project) do
                    Fabricate(:project, category: category, internal: true)
                  end

                  context "when belongs to them" do
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project,
                                                            user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
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
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project,
                                                            user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end
                end

                context "and internal" do
                  let(:project) do
                    Fabricate(:project, category: category, visible: false,
                                        internal: true)
                  end

                  context "when belongs to them" do
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project,
                                                            user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
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
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project,
                                                            user: current_user)
                    end

                    it { is_expected.to be_able_to(:create, search_result) }
                    it { is_expected.to be_able_to(:read, search_result) }
                    it { is_expected.to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end
                end

                context "and internal" do
                  let(:project) do
                    Fabricate(:project, category: category, internal: true)
                  end

                  context "when belongs to them" do
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project,
                                                            user: current_user)
                    end

                    it { is_expected.to be_able_to(:create, search_result) }
                    it { is_expected.to be_able_to(:read, search_result) }
                    it { is_expected.to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
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
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project,
                                                            user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end
                end

                context "and internal" do
                  let(:project) do
                    Fabricate(:project, category: category, visible: false,
                                        internal: true)
                  end

                  context "when belongs to them" do
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project,
                                                            user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
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
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project,
                                                            user: current_user)
                    end

                    it { is_expected.to be_able_to(:create, search_result) }
                    it { is_expected.to be_able_to(:read, search_result) }
                    it { is_expected.to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end
                end

                context "and internal" do
                  let(:project) do
                    Fabricate(:project, category: category, internal: true)
                  end

                  context "when belongs to them" do
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project,
                                                            user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
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
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project,
                                                            user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end
                end

                context "and internal" do
                  let(:project) do
                    Fabricate(:project, category: category, visible: false,
                                        internal: true)
                  end

                  context "when belongs to them" do
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project,
                                                            user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end
                end
              end

              context "while the search_result is closed" do
                let(:project) { Fabricate(:project, category: category) }

                context "when belongs to them" do
                  let(:search_result) do
                    Fabricate.build(:closed_issue_search_result,
                                    project: project, user: current_user)
                  end

                  it { is_expected.to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.to be_able_to(:update, search_result) }
                  it { is_expected.not_to be_able_to(:destroy, search_result) }
                end

                context "when doesn't belong to them" do
                  let(:search_result) do
                    Fabricate.build(:closed_issue_search_result,
                                    project: project)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.not_to be_able_to(:update, search_result) }
                  it { is_expected.not_to be_able_to(:destroy, search_result) }
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
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project,
                                                            user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end
                end

                context "and internal" do
                  let(:project) do
                    Fabricate(:project, category: category, internal: true)
                  end

                  context "when belongs to them" do
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project,
                                                            user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
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
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project,
                                                            user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end
                end

                context "and internal" do
                  let(:project) do
                    Fabricate(:project, category: category, visible: false,
                                        internal: true)
                  end

                  context "when belongs to them" do
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project,
                                                            user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
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
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project,
                                                            user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end
                end

                context "and internal" do
                  let(:project) do
                    Fabricate(:project, category: category, internal: true)
                  end

                  context "when belongs to them" do
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project,
                                                            user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
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
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project,
                                                            user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end
                end

                context "and internal" do
                  let(:project) do
                    Fabricate(:project, category: category, visible: false,
                                        internal: true)
                  end

                  context "when belongs to them" do
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project,
                                                            user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:issue_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end
                end
              end
            end
          end
        end
      end
    end

    context "when class_name is 'Task'" do
      describe "for an admin" do
        let(:category) { Fabricate(:category) }
        let(:project) { Fabricate(:project, category: category) }
        let(:admin) { Fabricate(:user_admin) }

        subject(:ability) { Ability.new(admin) }

        context "when search_result category is visible" do
          context "and external" do
            context "while project is visible" do
              context "and external" do
                context "when belongs to them" do
                  let(:search_result) do
                    Fabricate.build(:task_search_result, project: project,
                                                         user: admin)
                  end

                  it { is_expected.to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.to be_able_to(:update, search_result) }
                  it { is_expected.to be_able_to(:destroy, search_result) }
                end

                context "when doesn't belong to them" do
                  let(:search_result) do
                    Fabricate.build(:task_search_result, project: project)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.to be_able_to(:update, search_result) }
                  it { is_expected.to be_able_to(:destroy, search_result) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, internal: true)
                end

                context "when belongs to them" do
                  let(:search_result) do
                    Fabricate.build(:task_search_result, project: project,
                                                         user: admin)
                  end

                  it { is_expected.to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.to be_able_to(:update, search_result) }
                  it { is_expected.to be_able_to(:destroy, search_result) }
                end

                context "when doesn't belong to them" do
                  let(:search_result) do
                    Fabricate.build(:task_search_result, project: project)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.to be_able_to(:update, search_result) }
                  it { is_expected.to be_able_to(:destroy, search_result) }
                end
              end
            end

            context "while project is invisible" do
              context "and external" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false)
                end

                context "when belongs to them" do
                  let(:search_result) do
                    Fabricate.build(:task_search_result, project: project,
                                                         user: admin)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.to be_able_to(:update, search_result) }
                  it { is_expected.to be_able_to(:destroy, search_result) }
                end

                context "when doesn't belong to them" do
                  let(:search_result) do
                    Fabricate.build(:task_search_result, project: project)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.to be_able_to(:update, search_result) }
                  it { is_expected.to be_able_to(:destroy, search_result) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: true)
                end

                context "when belongs to them" do
                  let(:search_result) do
                    Fabricate.build(:task_search_result, project: project,
                                                         user: admin)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.to be_able_to(:update, search_result) }
                  it { is_expected.to be_able_to(:destroy, search_result) }
                end

                context "when doesn't belong to them" do
                  let(:search_result) do
                    Fabricate.build(:task_search_result, project: project)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.to be_able_to(:update, search_result) }
                  it { is_expected.to be_able_to(:destroy, search_result) }
                end
              end
            end
          end
        end

        context "when search_result category is invisible" do
          context "and external" do
            let(:category) { Fabricate(:category, visible: false) }

            context "while project is visible" do
              context "and external" do
                context "when belongs to them" do
                  let(:search_result) do
                    Fabricate.build(:task_search_result, project: project,
                                                         user: admin)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.to be_able_to(:update, search_result) }
                  it { is_expected.to be_able_to(:destroy, search_result) }
                end

                context "when doesn't belong to them" do
                  let(:search_result) do
                    Fabricate.build(:task_search_result, project: project)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.to be_able_to(:update, search_result) }
                  it { is_expected.to be_able_to(:destroy, search_result) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, internal: true)
                end

                context "when belongs to them" do
                  let(:search_result) do
                    Fabricate.build(:task_search_result, project: project,
                                                         user: admin)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.to be_able_to(:update, search_result) }
                  it { is_expected.to be_able_to(:destroy, search_result) }
                end

                context "when doesn't belong to them" do
                  let(:search_result) do
                    Fabricate.build(:task_search_result, project: project)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.to be_able_to(:update, search_result) }
                  it { is_expected.to be_able_to(:destroy, search_result) }
                end
              end
            end

            context "while project is invisible" do
              context "and external" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false)
                end

                context "when belongs to them" do
                  let(:search_result) do
                    Fabricate.build(:task_search_result, project: project,
                                                         user: admin)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.to be_able_to(:update, search_result) }
                  it { is_expected.to be_able_to(:destroy, search_result) }
                end

                context "when doesn't belong to them" do
                  let(:search_result) do
                    Fabricate.build(:task_search_result, project: project)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.to be_able_to(:update, search_result) }
                  it { is_expected.to be_able_to(:destroy, search_result) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: true)
                end

                context "when belongs to them" do
                  let(:search_result) do
                    Fabricate.build(:task_search_result, project: project,
                                                         user: admin)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.to be_able_to(:update, search_result) }
                  it { is_expected.to be_able_to(:destroy, search_result) }
                end

                context "when doesn't belong to them" do
                  let(:search_result) do
                    Fabricate.build(:task_search_result, project: project)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.to be_able_to(:update, search_result) }
                  it { is_expected.to be_able_to(:destroy, search_result) }
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

        context "when search_result category is visible" do
          context "and external" do
            context "while project is visible" do
              context "and external" do
                context "when belongs to them" do
                  let(:search_result) do
                    Fabricate.build(:task_search_result, project: project,
                                                         user: current_user)
                  end

                  it { is_expected.to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.to be_able_to(:update, search_result) }
                  it { is_expected.not_to be_able_to(:destroy, search_result) }
                end

                context "when doesn't belong to them" do
                  let(:search_result) do
                    Fabricate.build(:task_search_result, project: project)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.not_to be_able_to(:update, search_result) }
                  it { is_expected.not_to be_able_to(:destroy, search_result) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, internal: true)
                end

                context "when belongs to them" do
                  let(:search_result) do
                    Fabricate.build(:task_search_result, project: project,
                                                         user: current_user)
                  end

                  it { is_expected.to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.to be_able_to(:update, search_result) }
                  it { is_expected.not_to be_able_to(:destroy, search_result) }
                end

                context "when doesn't belong to them" do
                  let(:search_result) do
                    Fabricate.build(:task_search_result, project: project)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.not_to be_able_to(:update, search_result) }
                  it { is_expected.not_to be_able_to(:destroy, search_result) }
                end
              end
            end

            context "while project is invisible" do
              context "and external" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false)
                end

                context "when belongs to them" do
                  let(:search_result) do
                    Fabricate.build(:task_search_result, project: project,
                                                         user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.not_to be_able_to(:update, search_result) }
                  it { is_expected.not_to be_able_to(:destroy, search_result) }
                end

                context "when doesn't belong to them" do
                  let(:search_result) do
                    Fabricate.build(:task_search_result, project: project)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.not_to be_able_to(:update, search_result) }
                  it { is_expected.not_to be_able_to(:destroy, search_result) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: true)
                end

                context "when belongs to them" do
                  let(:search_result) do
                    Fabricate.build(:task_search_result, project: project,
                                                         user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.not_to be_able_to(:update, search_result) }
                  it { is_expected.not_to be_able_to(:destroy, search_result) }
                end

                context "when doesn't belong to them" do
                  let(:search_result) do
                    Fabricate.build(:task_search_result, project: project)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.not_to be_able_to(:update, search_result) }
                  it { is_expected.not_to be_able_to(:destroy, search_result) }
                end
              end
            end

            context "while search_result is closed" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:search_result) do
                  Fabricate.build(:closed_task_search_result,
                                  project: project, user: current_user)
                end

                it { is_expected.to be_able_to(:create, search_result) }
                it { is_expected.to be_able_to(:read, search_result) }
                it { is_expected.to be_able_to(:update, search_result) }
                it { is_expected.not_to be_able_to(:destroy, search_result) }
              end

              context "when doesn't belong to them" do
                let(:search_result) do
                  Fabricate.build(:closed_task_search_result, project: project)
                end

                it { is_expected.not_to be_able_to(:create, search_result) }
                it { is_expected.to be_able_to(:read, search_result) }
                it { is_expected.not_to be_able_to(:update, search_result) }
                it { is_expected.not_to be_able_to(:destroy, search_result) }
              end
            end
          end
        end

        context "when search_result category is invisible" do
          context "and external" do
            let(:category) { Fabricate(:category, visible: false) }

            context "while project is visible" do
              context "and external" do
                context "when belongs to them" do
                  let(:search_result) do
                    Fabricate.build(:task_search_result, project: project,
                                                         user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.not_to be_able_to(:update, search_result) }
                  it { is_expected.not_to be_able_to(:destroy, search_result) }
                end

                context "when doesn't belong to them" do
                  let(:search_result) do
                    Fabricate.build(:task_search_result, project: project)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.not_to be_able_to(:update, search_result) }
                  it { is_expected.not_to be_able_to(:destroy, search_result) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, internal: true)
                end

                context "when belongs to them" do
                  let(:search_result) do
                    Fabricate.build(:task_search_result, project: project,
                                                         user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.not_to be_able_to(:update, search_result) }
                  it { is_expected.not_to be_able_to(:destroy, search_result) }
                end

                context "when doesn't belong to them" do
                  let(:search_result) do
                    Fabricate.build(:task_search_result, project: project)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.not_to be_able_to(:update, search_result) }
                  it { is_expected.not_to be_able_to(:destroy, search_result) }
                end
              end
            end

            context "while project is invisible" do
              context "and external" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false)
                end

                context "when belongs to them" do
                  let(:search_result) do
                    Fabricate.build(:task_search_result, project: project,
                                                         user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.not_to be_able_to(:update, search_result) }
                  it { is_expected.not_to be_able_to(:destroy, search_result) }
                end

                context "when doesn't belong to them" do
                  let(:search_result) do
                    Fabricate.build(:task_search_result, project: project)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.not_to be_able_to(:update, search_result) }
                  it { is_expected.not_to be_able_to(:destroy, search_result) }
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: true)
                end

                context "when belongs to them" do
                  let(:search_result) do
                    Fabricate.build(:task_search_result, project: project,
                                                         user: current_user)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.not_to be_able_to(:update, search_result) }
                  it { is_expected.not_to be_able_to(:destroy, search_result) }
                end

                context "when doesn't belong to them" do
                  let(:search_result) do
                    Fabricate.build(:task_search_result, project: project)
                  end

                  it { is_expected.not_to be_able_to(:create, search_result) }
                  it { is_expected.to be_able_to(:read, search_result) }
                  it { is_expected.not_to be_able_to(:update, search_result) }
                  it { is_expected.not_to be_able_to(:destroy, search_result) }
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
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project,
                                                           user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end
                end

                context "and internal" do
                  let(:project) do
                    Fabricate(:project, category: category, internal: true)
                  end

                  context "when belongs to them" do
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project,
                                                           user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
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
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project,
                                                           user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end
                end

                context "and internal" do
                  let(:project) do
                    Fabricate(:project, category: category, visible: false,
                                        internal: true)
                  end

                  context "when belongs to them" do
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project,
                                                           user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
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
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project,
                                                           user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end
                end

                context "and internal" do
                  let(:project) do
                    Fabricate(:project, category: category, internal: true)
                  end

                  context "when belongs to them" do
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project,
                                                           user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
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
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project,
                                                           user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end
                end

                context "and internal" do
                  let(:project) do
                    Fabricate(:project, category: category, visible: false,
                                        internal: true)
                  end

                  context "when belongs to them" do
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project,
                                                           user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
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
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project,
                                                           user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end
                end

                context "and internal" do
                  let(:project) do
                    Fabricate(:project, category: category, internal: true)
                  end

                  context "when belongs to them" do
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project,
                                                           user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
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
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project,
                                                           user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end
                end

                context "and internal" do
                  let(:project) do
                    Fabricate(:project, category: category, visible: false,
                                        internal: true)
                  end

                  context "when belongs to them" do
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project,
                                                           user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
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
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project,
                                                           user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end
                end

                context "and internal" do
                  let(:project) do
                    Fabricate(:project, category: category, internal: true)
                  end

                  context "when belongs to them" do
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project,
                                                           user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
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
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project,
                                                           user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end
                end

                context "and internal" do
                  let(:project) do
                    Fabricate(:project, category: category, visible: false,
                                        internal: true)
                  end

                  context "when belongs to them" do
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project,
                                                           user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
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
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project,
                                                           user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end
                end

                context "and internal" do
                  let(:project) do
                    Fabricate(:project, category: category, internal: true)
                  end

                  context "when belongs to them" do
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project,
                                                           user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
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
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project,
                                                           user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end
                end

                context "and internal" do
                  let(:project) do
                    Fabricate(:project, category: category, visible: false,
                                        internal: true)
                  end

                  context "when belongs to them" do
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project,
                                                           user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
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
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project,
                                                           user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end
                end

                context "and internal" do
                  let(:project) do
                    Fabricate(:project, category: category, internal: true)
                  end

                  context "when belongs to them" do
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project,
                                                           user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
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
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project,
                                                           user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end
                end

                context "and internal" do
                  let(:project) do
                    Fabricate(:project, category: category, visible: false,
                                        internal: true)
                  end

                  context "when belongs to them" do
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project,
                                                           user: current_user)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end

                  context "when doesn't belong to them" do
                    let(:search_result) do
                      Fabricate.build(:task_search_result, project: project)
                    end

                    it { is_expected.not_to be_able_to(:create, search_result) }
                    it { is_expected.not_to be_able_to(:read, search_result) }
                    it { is_expected.not_to be_able_to(:update, search_result) }
                    it do
                      is_expected.not_to be_able_to(:destroy, search_result)
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
