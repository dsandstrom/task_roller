# frozen_string_literal: true

require "rails_helper"
require "cancan/matchers"

RSpec.describe Ability do
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

          context "while the issue is closed" do
            let(:project) { Fabricate(:project, category: category) }

            context "when belongs to them" do
              let(:issue) do
                Fabricate(:closed_issue, project: project, user: admin)
              end

              it { is_expected.to be_able_to(:create, issue) }
              it { is_expected.to be_able_to(:read, issue) }
              it { is_expected.to be_able_to(:update, issue) }
              it { is_expected.to be_able_to(:destroy, issue) }
            end

            context "when doesn't belong to them" do
              let(:issue) { Fabricate(:closed_issue, project: project) }

              it { is_expected.not_to be_able_to(:create, issue) }
              it { is_expected.to be_able_to(:read, issue) }
              it { is_expected.to be_able_to(:update, issue) }
              it { is_expected.to be_able_to(:destroy, issue) }
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
                it { is_expected.not_to be_able_to(:update, issue) }
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
                it { is_expected.not_to be_able_to(:update, issue) }
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

          context "while issue is closed" do
            let(:project) { Fabricate(:project, category: category) }

            context "when belongs to them" do
              let(:issue) do
                Fabricate(:closed_issue, project: project, user: current_user)
              end

              it { is_expected.to be_able_to(:create, issue) }
              it { is_expected.to be_able_to(:read, issue) }
              it { is_expected.to be_able_to(:update, issue) }
              it { is_expected.not_to be_able_to(:destroy, issue) }
            end

            context "when doesn't belong to them" do
              let(:issue) { Fabricate(:closed_issue, project: project) }

              it { is_expected.not_to be_able_to(:create, issue) }
              it { is_expected.to be_able_to(:read, issue) }
              it { is_expected.not_to be_able_to(:update, issue) }
              it { is_expected.not_to be_able_to(:destroy, issue) }
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
                it { is_expected.not_to be_able_to(:update, issue) }
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
                it { is_expected.not_to be_able_to(:update, issue) }
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
                it { is_expected.not_to be_able_to(:update, issue) }
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
                it { is_expected.not_to be_able_to(:update, issue) }
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

            context "while the issue is closed" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:issue) do
                  Fabricate(:closed_issue, project: project, user: current_user)
                end

                it { is_expected.to be_able_to(:create, issue) }
                it { is_expected.to be_able_to(:read, issue) }
                it { is_expected.to be_able_to(:update, issue) }
                it { is_expected.not_to be_able_to(:destroy, issue) }
              end

              context "when doesn't belong to them" do
                let(:issue) { Fabricate(:closed_issue, project: project) }

                it { is_expected.not_to be_able_to(:create, issue) }
                it { is_expected.to be_able_to(:read, issue) }
                it { is_expected.not_to be_able_to(:update, issue) }
                it { is_expected.not_to be_able_to(:destroy, issue) }
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

            context "while the issue is closed" do
              let(:project) { Fabricate(:project, category: category) }

              context "when belongs to them" do
                let(:issue) do
                  Fabricate(:closed_issue, project: project, user: current_user)
                end

                it { is_expected.to be_able_to(:create, issue) }
                it { is_expected.to be_able_to(:read, issue) }
                it { is_expected.to be_able_to(:update, issue) }
                it { is_expected.not_to be_able_to(:destroy, issue) }
              end

              context "when doesn't belong to them" do
                let(:issue) { Fabricate(:closed_issue, project: project) }

                it { is_expected.not_to be_able_to(:create, issue) }
                it { is_expected.to be_able_to(:read, issue) }
                it { is_expected.not_to be_able_to(:update, issue) }
                it { is_expected.not_to be_able_to(:destroy, issue) }
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

        context "for a totally visible issue" do
          let(:category) { Fabricate(:category) }
          let(:project) { Fabricate(:project, category: category) }
          let(:issue) { Fabricate(:issue, project: project) }

          context "when their closure" do
            let(:issue_closure) do
              Fabricate(:issue_closure, issue: issue, user: current_user)
            end

            it { is_expected.to be_able_to(:create, issue_closure) }
            it { is_expected.to be_able_to(:read, issue_closure) }
            it { is_expected.not_to be_able_to(:update, issue_closure) }
            it { is_expected.to be_able_to(:destroy, issue_closure) }
          end

          context "when someone else's closure" do
            let(:issue_closure) { Fabricate(:issue_closure, issue: issue) }

            it { is_expected.not_to be_able_to(:create, issue_closure) }
            it { is_expected.to be_able_to(:read, issue_closure) }
            it { is_expected.not_to be_able_to(:update, issue_closure) }
            it { is_expected.to be_able_to(:destroy, issue_closure) }
          end
        end

        context "for an issue from an internal category" do
          let(:category) { Fabricate(:internal_category) }
          let(:project) { Fabricate(:project, category: category) }
          let(:issue) { Fabricate(:issue, project: project) }

          context "when their closure" do
            let(:issue_closure) do
              Fabricate(:issue_closure, issue: issue, user: current_user)
            end

            it { is_expected.to be_able_to(:create, issue_closure) }
            it { is_expected.to be_able_to(:read, issue_closure) }
            it { is_expected.not_to be_able_to(:update, issue_closure) }
            it { is_expected.to be_able_to(:destroy, issue_closure) }
          end
        end

        context "for an issue from an invisible category" do
          let(:category) { Fabricate(:invisible_category) }
          let(:project) { Fabricate(:project, category: category) }
          let(:issue) { Fabricate(:issue, project: project) }

          context "when their closure" do
            let(:issue_closure) do
              Fabricate(:issue_closure, issue: issue, user: current_user)
            end

            it { is_expected.to be_able_to(:create, issue_closure) }
            it { is_expected.to be_able_to(:read, issue_closure) }
            it { is_expected.not_to be_able_to(:update, issue_closure) }
            it { is_expected.to be_able_to(:destroy, issue_closure) }
          end
        end
      end
    end

    %i[reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        subject(:ability) { Ability.new(current_user) }

        context "for a totally visible issue" do
          context "when their closure" do
            let(:issue_closure) do
              Fabricate(:issue_closure, user: current_user)
            end

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

        context "for an issue from an internal category" do
          let(:category) { Fabricate(:internal_category) }
          let(:project) { Fabricate(:project, category: category) }
          let(:issue) { Fabricate(:issue, project: project) }

          context "when their closure" do
            let(:issue_closure) do
              Fabricate(:issue_closure, issue: issue, user: current_user)
            end

            it { is_expected.to be_able_to(:create, issue_closure) }
            it { is_expected.to be_able_to(:read, issue_closure) }
            it { is_expected.not_to be_able_to(:update, issue_closure) }
            it { is_expected.not_to be_able_to(:destroy, issue_closure) }
          end
        end

        context "for an issue from an invisible category" do
          let(:category) { Fabricate(:invisible_category) }
          let(:project) { Fabricate(:project, category: category) }
          let(:issue) { Fabricate(:issue, project: project) }

          context "when their closure" do
            let(:issue_closure) do
              Fabricate(:issue_closure, issue: issue, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, issue_closure) }
            it { is_expected.to be_able_to(:read, issue_closure) }
            it { is_expected.not_to be_able_to(:update, issue_closure) }
            it { is_expected.not_to be_able_to(:destroy, issue_closure) }
          end
        end
      end
    end

    %i[worker].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        subject(:ability) { Ability.new(current_user) }

        context "for a totally visible issue" do
          let(:category) { Fabricate(:category) }
          let(:project) { Fabricate(:project, category: category) }
          let(:issue) { Fabricate(:issue, project: project) }

          let(:issue_closure) do
            Fabricate(:issue_closure, issue: issue, user: current_user)
          end

          it { is_expected.not_to be_able_to(:create, issue_closure) }
          it { is_expected.to be_able_to(:read, issue_closure) }
          it { is_expected.not_to be_able_to(:update, issue_closure) }
          it { is_expected.not_to be_able_to(:destroy, issue_closure) }
        end

        context "for an issue from an internal category" do
          let(:category) { Fabricate(:internal_category) }
          let(:project) { Fabricate(:project, category: category) }
          let(:issue) { Fabricate(:issue, project: project) }

          let(:issue_closure) do
            Fabricate(:issue_closure, issue: issue, user: current_user)
          end

          it { is_expected.to be_able_to(:read, issue_closure) }
        end

        context "for an issue from an invisible category" do
          let(:category) { Fabricate(:invisible_category) }
          let(:project) { Fabricate(:project, category: category) }
          let(:issue) { Fabricate(:issue, project: project) }

          let(:issue_closure) do
            Fabricate(:issue_closure, issue: issue, user: current_user)
          end

          it { is_expected.not_to be_able_to(:read, issue_closure) }
        end
      end
    end

    %i[reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        subject(:ability) { Ability.new(current_user) }

        context "for a totally visible issue" do
          let(:category) { Fabricate(:category) }
          let(:project) { Fabricate(:project, category: category) }
          let(:issue) { Fabricate(:issue, project: project) }

          let(:issue_closure) do
            Fabricate(:issue_closure, issue: issue, user: current_user)
          end

          it { is_expected.not_to be_able_to(:create, issue_closure) }
          it { is_expected.to be_able_to(:read, issue_closure) }
          it { is_expected.not_to be_able_to(:update, issue_closure) }
          it { is_expected.not_to be_able_to(:destroy, issue_closure) }
        end

        context "for an issue from an internal category" do
          let(:category) { Fabricate(:internal_category) }
          let(:project) { Fabricate(:project, category: category) }
          let(:issue) { Fabricate(:issue, project: project) }

          let(:issue_closure) do
            Fabricate(:issue_closure, issue: issue, user: current_user)
          end

          it { is_expected.not_to be_able_to(:read, issue_closure) }
        end

        context "for an issue from an invisible category" do
          let(:category) { Fabricate(:invisible_category) }
          let(:project) { Fabricate(:project, category: category) }
          let(:issue) { Fabricate(:issue, project: project) }

          let(:issue_closure) do
            Fabricate(:issue_closure, issue: issue, user: current_user)
          end

          it { is_expected.not_to be_able_to(:read, issue_closure) }
        end
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

                it { is_expected.not_to be_able_to(:read, issue_comment) }
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

                it { is_expected.not_to be_able_to(:read, issue_comment) }
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

                it { is_expected.not_to be_able_to(:read, issue_comment) }
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

                it { is_expected.not_to be_able_to(:read, issue_comment) }
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

                it { is_expected.not_to be_able_to(:read, issue_comment) }
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

                it { is_expected.not_to be_able_to(:read, issue_comment) }
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

                it { is_expected.not_to be_able_to(:read, issue_comment) }
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

                it { is_expected.not_to be_able_to(:read, issue_comment) }
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

                it { is_expected.not_to be_able_to(:read, issue_comment) }
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

                it { is_expected.not_to be_able_to(:read, issue_comment) }
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

                it { is_expected.not_to be_able_to(:read, issue_comment) }
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

                it { is_expected.not_to be_able_to(:read, issue_comment) }
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

                it { is_expected.not_to be_able_to(:read, issue_comment) }
              end
            end
          end
        end
      end
    end
  end

  describe "IssueConnection model" do
    %i[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        subject(:ability) { Ability.new(current_user) }

        context "for a totally visible issue" do
          let(:project) { Fabricate(:project) }
          let(:issue) { Fabricate(:issue, project: project) }

          context "when their connection" do
            let(:issue_connection) do
              Fabricate(:issue_connection, source: issue, user: current_user)
            end

            it { is_expected.to be_able_to(:create, issue_connection) }
            it { is_expected.to be_able_to(:read, issue_connection) }
            it { is_expected.to be_able_to(:update, issue_connection) }
            it { is_expected.to be_able_to(:destroy, issue_connection) }
          end

          context "when someone else's connection" do
            let(:issue_connection) do
              Fabricate(:issue_connection, source: issue)
            end

            it { is_expected.not_to be_able_to(:create, issue_connection) }
            it { is_expected.to be_able_to(:read, issue_connection) }
            it { is_expected.not_to be_able_to(:update, issue_connection) }
            it { is_expected.to be_able_to(:destroy, issue_connection) }
          end
        end

        context "for an issue from an internal project" do
          let(:project) { Fabricate(:internal_project) }
          let(:issue) { Fabricate(:issue, project: project) }

          context "when their connection" do
            let(:issue_connection) do
              Fabricate(:issue_connection, source: issue, user: current_user)
            end

            it { is_expected.to be_able_to(:create, issue_connection) }
            it { is_expected.to be_able_to(:read, issue_connection) }
            it { is_expected.to be_able_to(:update, issue_connection) }
            it { is_expected.to be_able_to(:destroy, issue_connection) }
          end

          context "when someone else's connection" do
            let(:issue_connection) do
              Fabricate(:issue_connection, source: issue)
            end

            it { is_expected.not_to be_able_to(:create, issue_connection) }
            it { is_expected.to be_able_to(:read, issue_connection) }
            it { is_expected.not_to be_able_to(:update, issue_connection) }
            it { is_expected.to be_able_to(:destroy, issue_connection) }
          end
        end

        context "for an issue from an invisible project" do
          let(:project) { Fabricate(:invisible_project) }
          let(:issue) { Fabricate(:issue, project: project) }

          context "when their connection" do
            let(:issue_connection) do
              Fabricate(:issue_connection, source: issue, user: current_user)
            end

            it { is_expected.to be_able_to(:create, issue_connection) }
            it { is_expected.to be_able_to(:read, issue_connection) }
            it { is_expected.to be_able_to(:update, issue_connection) }
            it { is_expected.to be_able_to(:destroy, issue_connection) }
          end

          context "when someone else's connection" do
            let(:issue_connection) do
              Fabricate(:issue_connection, source: issue)
            end

            it { is_expected.not_to be_able_to(:create, issue_connection) }
            it { is_expected.to be_able_to(:read, issue_connection) }
            it { is_expected.not_to be_able_to(:update, issue_connection) }
            it { is_expected.to be_able_to(:destroy, issue_connection) }
          end
        end
      end
    end

    %i[reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        subject(:ability) { Ability.new(current_user) }

        context "for a totally visible issue" do
          let(:project) { Fabricate(:project) }
          let(:issue) { Fabricate(:issue, project: project) }

          context "when their connection" do
            let(:issue_connection) do
              Fabricate(:issue_connection, source: issue, user: current_user)
            end

            it { is_expected.to be_able_to(:create, issue_connection) }
            it { is_expected.to be_able_to(:read, issue_connection) }
            it { is_expected.to be_able_to(:update, issue_connection) }
            it { is_expected.to be_able_to(:destroy, issue_connection) }
          end

          context "when someone else's connection" do
            let(:issue_connection) do
              Fabricate(:issue_connection, source: issue)
            end

            it { is_expected.not_to be_able_to(:create, issue_connection) }
            it { is_expected.to be_able_to(:read, issue_connection) }
            it { is_expected.not_to be_able_to(:update, issue_connection) }
            it { is_expected.to be_able_to(:destroy, issue_connection) }
          end
        end

        context "for an issue from an internal project" do
          let(:project) { Fabricate(:internal_project) }
          let(:issue) { Fabricate(:issue, project: project) }

          context "when their connection" do
            let(:issue_connection) do
              Fabricate(:issue_connection, source: issue, user: current_user)
            end

            it { is_expected.to be_able_to(:create, issue_connection) }
            it { is_expected.to be_able_to(:read, issue_connection) }
            it { is_expected.to be_able_to(:update, issue_connection) }
            it { is_expected.to be_able_to(:destroy, issue_connection) }
          end

          context "when someone else's connection" do
            let(:issue_connection) do
              Fabricate(:issue_connection, source: issue)
            end

            it { is_expected.not_to be_able_to(:create, issue_connection) }
            it { is_expected.to be_able_to(:read, issue_connection) }
            it { is_expected.not_to be_able_to(:update, issue_connection) }
            it { is_expected.to be_able_to(:destroy, issue_connection) }
          end
        end

        context "for an issue from an invisible project" do
          let(:project) { Fabricate(:invisible_project) }
          let(:issue) { Fabricate(:issue, project: project) }

          context "when their connection" do
            let(:issue_connection) do
              Fabricate(:issue_connection, source: issue, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, issue_connection) }
            it { is_expected.to be_able_to(:read, issue_connection) }
            it { is_expected.not_to be_able_to(:update, issue_connection) }
            it { is_expected.not_to be_able_to(:destroy, issue_connection) }
          end

          context "when someone else's connection" do
            let(:issue_connection) do
              Fabricate(:issue_connection, source: issue)
            end

            it { is_expected.not_to be_able_to(:create, issue_connection) }
            it { is_expected.to be_able_to(:read, issue_connection) }
            it { is_expected.not_to be_able_to(:update, issue_connection) }
            it { is_expected.not_to be_able_to(:destroy, issue_connection) }
          end
        end
      end
    end

    %i[worker].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        let(:issue_connection) do
          Fabricate(:issue_connection, source: issue, user: current_user)
        end

        subject(:ability) { Ability.new(current_user) }

        context "for a totally visible issue" do
          let(:project) { Fabricate(:project) }
          let(:issue) { Fabricate(:issue, project: project) }

          it { is_expected.not_to be_able_to(:create, issue_connection) }
          it { is_expected.to be_able_to(:read, issue_connection) }
          it { is_expected.not_to be_able_to(:update, issue_connection) }
          it { is_expected.not_to be_able_to(:destroy, issue_connection) }
        end

        context "for an issue from an internal project" do
          let(:project) { Fabricate(:internal_project) }
          let(:issue) { Fabricate(:issue, project: project) }

          context "when their connection" do
            let(:issue_connection) do
              Fabricate(:issue_connection, source: issue, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, issue_connection) }
            it { is_expected.to be_able_to(:read, issue_connection) }
            it { is_expected.not_to be_able_to(:update, issue_connection) }
            it { is_expected.not_to be_able_to(:destroy, issue_connection) }
          end
        end

        context "for an issue from an invisible project" do
          let(:project) { Fabricate(:invisible_project) }
          let(:issue) { Fabricate(:issue, project: project) }

          context "when their connection" do
            let(:issue_connection) do
              Fabricate(:issue_connection, source: issue, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, issue_connection) }
            it { is_expected.not_to be_able_to(:read, issue_connection) }
            it { is_expected.not_to be_able_to(:update, issue_connection) }
            it { is_expected.not_to be_able_to(:destroy, issue_connection) }
          end
        end
      end
    end

    %i[reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        let(:issue_connection) do
          Fabricate(:issue_connection, source: issue, user: current_user)
        end

        subject(:ability) { Ability.new(current_user) }

        context "for a totally visible issue" do
          let(:project) { Fabricate(:project) }
          let(:issue) { Fabricate(:issue, project: project) }

          it { is_expected.not_to be_able_to(:create, issue_connection) }
          it { is_expected.to be_able_to(:read, issue_connection) }
          it { is_expected.not_to be_able_to(:update, issue_connection) }
          it { is_expected.not_to be_able_to(:destroy, issue_connection) }
        end

        context "for an issue from an internal project" do
          let(:project) { Fabricate(:internal_project) }
          let(:issue) { Fabricate(:issue, project: project) }

          context "when their connection" do
            let(:issue_connection) do
              Fabricate(:issue_connection, source: issue, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, issue_connection) }
            it { is_expected.not_to be_able_to(:read, issue_connection) }
            it { is_expected.not_to be_able_to(:update, issue_connection) }
            it { is_expected.not_to be_able_to(:destroy, issue_connection) }
          end
        end

        context "for an issue from an invisible project" do
          let(:project) { Fabricate(:invisible_project) }
          let(:issue) { Fabricate(:issue, project: project) }

          context "when their connection" do
            let(:issue_connection) do
              Fabricate(:issue_connection, source: issue, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, issue_connection) }
            it { is_expected.not_to be_able_to(:read, issue_connection) }
            it { is_expected.not_to be_able_to(:update, issue_connection) }
            it { is_expected.not_to be_able_to(:destroy, issue_connection) }
          end
        end
      end
    end
  end

  describe "IssueReopening model" do
    %i[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        subject(:ability) { Ability.new(current_user) }

        context "for a totally visible issue" do
          let(:project) { Fabricate(:project) }
          let(:issue) { Fabricate(:issue, project: project) }

          context "when their closure" do
            let(:issue_reopening) do
              Fabricate(:issue_reopening, issue: issue, user: current_user)
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

        context "for an issue from an internal project" do
          let(:project) { Fabricate(:internal_project) }
          let(:issue) { Fabricate(:issue, project: project) }

          context "when their closure" do
            let(:issue_reopening) do
              Fabricate(:issue_reopening, issue: issue, user: current_user)
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

        context "for an issue from an invisible project" do
          let(:project) { Fabricate(:invisible_project) }
          let(:issue) { Fabricate(:issue, project: project) }

          context "when their closure" do
            let(:issue_reopening) do
              Fabricate(:issue_reopening, issue: issue, user: current_user)
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
    end

    %i[reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        subject(:ability) { Ability.new(current_user) }

        context "for a totally visible issue" do
          let(:project) { Fabricate(:project) }
          let(:issue) { Fabricate(:issue, project: project) }

          context "when their reopening" do
            let(:issue_reopening) do
              Fabricate(:issue_reopening, issue: issue, user: current_user)
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

        context "for an issue from an internal project" do
          let(:project) { Fabricate(:internal_project) }
          let(:issue) { Fabricate(:issue, project: project) }

          context "when their closure" do
            let(:issue_reopening) do
              Fabricate(:issue_reopening, issue: issue, user: current_user)
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

        context "for an issue from an invisible project" do
          let(:project) { Fabricate(:invisible_project) }
          let(:issue) { Fabricate(:issue, project: project) }

          context "when their closure" do
            let(:issue_reopening) do
              Fabricate(:issue_reopening, issue: issue, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, issue_reopening) }
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
    end

    %i[worker].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        let(:issue_reopening) do
          Fabricate(:issue_reopening, issue: issue, user: current_user)
        end

        subject(:ability) { Ability.new(current_user) }

        context "for a totally visible issue" do
          let(:project) { Fabricate(:project) }
          let(:issue) { Fabricate(:issue, project: project) }

          it { is_expected.not_to be_able_to(:create, issue_reopening) }
          it { is_expected.to be_able_to(:read, issue_reopening) }
          it { is_expected.not_to be_able_to(:update, issue_reopening) }
          it { is_expected.not_to be_able_to(:destroy, issue_reopening) }
        end

        context "for an issue from an internal project" do
          let(:project) { Fabricate(:internal_project) }
          let(:issue) { Fabricate(:issue, project: project) }

          it { is_expected.not_to be_able_to(:create, issue_reopening) }
          it { is_expected.to be_able_to(:read, issue_reopening) }
          it { is_expected.not_to be_able_to(:update, issue_reopening) }
          it { is_expected.not_to be_able_to(:destroy, issue_reopening) }
        end

        context "for an issue from an invisible project" do
          let(:project) { Fabricate(:invisible_project) }
          let(:issue) { Fabricate(:issue, project: project) }

          it { is_expected.not_to be_able_to(:create, issue_reopening) }
          it { is_expected.not_to be_able_to(:read, issue_reopening) }
          it { is_expected.not_to be_able_to(:update, issue_reopening) }
          it { is_expected.not_to be_able_to(:destroy, issue_reopening) }
        end
      end
    end

    %i[reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        let(:issue_reopening) do
          Fabricate(:issue_reopening, issue: issue, user: current_user)
        end

        subject(:ability) { Ability.new(current_user) }

        context "for a totally visible issue" do
          let(:project) { Fabricate(:project) }
          let(:issue) { Fabricate(:issue, project: project) }

          it { is_expected.not_to be_able_to(:create, issue_reopening) }
          it { is_expected.to be_able_to(:read, issue_reopening) }
          it { is_expected.not_to be_able_to(:update, issue_reopening) }
          it { is_expected.not_to be_able_to(:destroy, issue_reopening) }
        end

        context "for an issue from an internal project" do
          let(:project) { Fabricate(:internal_project) }
          let(:issue) { Fabricate(:issue, project: project) }

          it { is_expected.not_to be_able_to(:create, issue_reopening) }
          it { is_expected.not_to be_able_to(:read, issue_reopening) }
          it { is_expected.not_to be_able_to(:update, issue_reopening) }
          it { is_expected.not_to be_able_to(:destroy, issue_reopening) }
        end

        context "for an issue from an invisible project" do
          let(:project) { Fabricate(:invisible_project) }
          let(:issue) { Fabricate(:issue, project: project) }

          it { is_expected.not_to be_able_to(:create, issue_reopening) }
          it { is_expected.not_to be_able_to(:read, issue_reopening) }
          it { is_expected.not_to be_able_to(:update, issue_reopening) }
          it { is_expected.not_to be_able_to(:destroy, issue_reopening) }
        end
      end
    end
  end

  describe "IssueSubscription model" do
    %i[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        context "for a totally visible issue" do
          let(:project) { Fabricate(:project) }
          let(:issue) { Fabricate(:issue, project: project) }

          context "when belongs to them" do
            let(:issue_subscription) do
              Fabricate(:issue_subscription, issue: issue, user: current_user)
            end

            it { is_expected.to be_able_to(:create, issue_subscription) }
            it { is_expected.to be_able_to(:read, issue_subscription) }
            it { is_expected.to be_able_to(:update, issue_subscription) }
            it { is_expected.to be_able_to(:destroy, issue_subscription) }
          end

          context "when doesn't belong to them" do
            let(:issue_subscription) do
              Fabricate(:issue_subscription, issue: issue)
            end

            it { is_expected.not_to be_able_to(:create, issue_subscription) }
            it { is_expected.not_to be_able_to(:read, issue_subscription) }
            it { is_expected.not_to be_able_to(:update, issue_subscription) }
            it { is_expected.not_to be_able_to(:destroy, issue_subscription) }
          end
        end

        context "for an issue from an internal project" do
          let(:project) { Fabricate(:internal_project) }
          let(:issue) { Fabricate(:issue, project: project) }

          context "when belongs to them" do
            let(:issue_subscription) do
              Fabricate(:issue_subscription, issue: issue, user: current_user)
            end

            it { is_expected.to be_able_to(:create, issue_subscription) }
            it { is_expected.to be_able_to(:read, issue_subscription) }
            it { is_expected.to be_able_to(:update, issue_subscription) }
            it { is_expected.to be_able_to(:destroy, issue_subscription) }
          end

          context "when doesn't belong to them" do
            let(:issue_subscription) do
              Fabricate(:issue_subscription, issue: issue)
            end

            it { is_expected.not_to be_able_to(:create, issue_subscription) }
            it { is_expected.not_to be_able_to(:read, issue_subscription) }
            it { is_expected.not_to be_able_to(:update, issue_subscription) }
            it { is_expected.not_to be_able_to(:destroy, issue_subscription) }
          end
        end

        context "for an issue from an invisible project" do
          let(:project) { Fabricate(:invisible_project) }
          let(:issue) { Fabricate(:issue, project: project) }

          context "when belongs to them" do
            let(:issue_subscription) do
              Fabricate(:issue_subscription, issue: issue, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, issue_subscription) }
            it { is_expected.not_to be_able_to(:read, issue_subscription) }
            it { is_expected.not_to be_able_to(:update, issue_subscription) }
            it { is_expected.not_to be_able_to(:destroy, issue_subscription) }
          end

          context "when doesn't belong to them" do
            let(:issue_subscription) do
              Fabricate(:issue_subscription, issue: issue)
            end

            it { is_expected.not_to be_able_to(:create, issue_subscription) }
            it { is_expected.not_to be_able_to(:read, issue_subscription) }
            it { is_expected.not_to be_able_to(:update, issue_subscription) }
            it { is_expected.not_to be_able_to(:destroy, issue_subscription) }
          end
        end
      end
    end

    %i[worker].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        context "for a totally visible issue" do
          let(:project) { Fabricate(:project) }
          let(:issue) { Fabricate(:issue, project: project) }

          context "when belongs to them" do
            let(:issue_subscription) do
              Fabricate(:issue_subscription, issue: issue, user: current_user)
            end

            it { is_expected.to be_able_to(:create, issue_subscription) }
            it { is_expected.to be_able_to(:read, issue_subscription) }
            it { is_expected.to be_able_to(:update, issue_subscription) }
            it { is_expected.to be_able_to(:destroy, issue_subscription) }
          end

          context "when doesn't belong to them" do
            let(:issue_subscription) do
              Fabricate(:issue_subscription, issue: issue)
            end

            it { is_expected.not_to be_able_to(:create, issue_subscription) }
            it { is_expected.not_to be_able_to(:read, issue_subscription) }
            it { is_expected.not_to be_able_to(:update, issue_subscription) }
            it { is_expected.not_to be_able_to(:destroy, issue_subscription) }
          end
        end

        context "for an issue from an internal project" do
          let(:project) { Fabricate(:internal_project) }
          let(:issue) { Fabricate(:issue, project: project) }

          context "when belongs to them" do
            let(:issue_subscription) do
              Fabricate(:issue_subscription, issue: issue, user: current_user)
            end

            it { is_expected.to be_able_to(:create, issue_subscription) }
            it { is_expected.to be_able_to(:read, issue_subscription) }
            it { is_expected.to be_able_to(:update, issue_subscription) }
            it { is_expected.to be_able_to(:destroy, issue_subscription) }
          end

          context "when doesn't belong to them" do
            let(:issue_subscription) do
              Fabricate(:issue_subscription, issue: issue)
            end

            it { is_expected.not_to be_able_to(:create, issue_subscription) }
            it { is_expected.not_to be_able_to(:read, issue_subscription) }
            it { is_expected.not_to be_able_to(:update, issue_subscription) }
            it { is_expected.not_to be_able_to(:destroy, issue_subscription) }
          end
        end

        context "for an issue from an invisible project" do
          let(:project) { Fabricate(:invisible_project) }
          let(:issue) { Fabricate(:issue, project: project) }

          context "when belongs to them" do
            let(:issue_subscription) do
              Fabricate(:issue_subscription, issue: issue, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, issue_subscription) }
            it { is_expected.not_to be_able_to(:read, issue_subscription) }
            it { is_expected.not_to be_able_to(:update, issue_subscription) }
            it { is_expected.not_to be_able_to(:destroy, issue_subscription) }
          end

          context "when doesn't belong to them" do
            let(:issue_subscription) do
              Fabricate(:issue_subscription, issue: issue)
            end

            it { is_expected.not_to be_able_to(:create, issue_subscription) }
            it { is_expected.not_to be_able_to(:read, issue_subscription) }
            it { is_expected.not_to be_able_to(:update, issue_subscription) }
            it { is_expected.not_to be_able_to(:destroy, issue_subscription) }
          end
        end
      end
    end

    %i[reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        context "for a totally visible issue" do
          let(:project) { Fabricate(:project) }
          let(:issue) { Fabricate(:issue, project: project) }

          context "when belongs to them" do
            let(:issue_subscription) do
              Fabricate(:issue_subscription, issue: issue, user: current_user)
            end

            it { is_expected.to be_able_to(:create, issue_subscription) }
            it { is_expected.to be_able_to(:read, issue_subscription) }
            it { is_expected.to be_able_to(:update, issue_subscription) }
            it { is_expected.to be_able_to(:destroy, issue_subscription) }
          end

          context "when doesn't belong to them" do
            let(:issue_subscription) do
              Fabricate(:issue_subscription, issue: issue)
            end

            it { is_expected.not_to be_able_to(:create, issue_subscription) }
            it { is_expected.not_to be_able_to(:read, issue_subscription) }
            it { is_expected.not_to be_able_to(:update, issue_subscription) }
            it { is_expected.not_to be_able_to(:destroy, issue_subscription) }
          end
        end

        context "for an issue from an internal project" do
          let(:project) { Fabricate(:internal_project) }
          let(:issue) { Fabricate(:issue, project: project) }

          context "when belongs to them" do
            let(:issue_subscription) do
              Fabricate(:issue_subscription, issue: issue, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, issue_subscription) }
            it { is_expected.not_to be_able_to(:read, issue_subscription) }
            it { is_expected.not_to be_able_to(:update, issue_subscription) }
            it { is_expected.not_to be_able_to(:destroy, issue_subscription) }
          end

          context "when doesn't belong to them" do
            let(:issue_subscription) do
              Fabricate(:issue_subscription, issue: issue)
            end

            it { is_expected.not_to be_able_to(:create, issue_subscription) }
            it { is_expected.not_to be_able_to(:read, issue_subscription) }
            it { is_expected.not_to be_able_to(:update, issue_subscription) }
            it { is_expected.not_to be_able_to(:destroy, issue_subscription) }
          end
        end

        context "for an issue from an invisible project" do
          let(:project) { Fabricate(:invisible_project) }
          let(:issue) { Fabricate(:issue, project: project) }

          context "when belongs to them" do
            let(:issue_subscription) do
              Fabricate(:issue_subscription, issue: issue, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, issue_subscription) }
            it { is_expected.not_to be_able_to(:read, issue_subscription) }
            it { is_expected.not_to be_able_to(:update, issue_subscription) }
            it { is_expected.not_to be_able_to(:destroy, issue_subscription) }
          end

          context "when doesn't belong to them" do
            let(:issue_subscription) do
              Fabricate(:issue_subscription, issue: issue)
            end

            it { is_expected.not_to be_able_to(:create, issue_subscription) }
            it { is_expected.not_to be_able_to(:read, issue_subscription) }
            it { is_expected.not_to be_able_to(:update, issue_subscription) }
            it { is_expected.not_to be_able_to(:destroy, issue_subscription) }
          end
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

  describe "Resolution model" do
    describe "for an admin" do
      let(:admin) { Fabricate(:user_admin) }
      subject(:ability) { Ability.new(admin) }

      context "when issue is totally visible" do
        let(:project) { Fabricate(:project) }

        context "and resolution/issue belong to them" do
          let(:issue) { Fabricate(:issue, project: project, user: admin) }
          let(:resolution) { Fabricate(:resolution, issue: issue, user: admin) }

          it { is_expected.to be_able_to(:create, resolution) }
          it { is_expected.to be_able_to(:read, resolution) }
          it { is_expected.to be_able_to(:update, resolution) }
          it { is_expected.to be_able_to(:destroy, resolution) }
        end

        context "and issue doesn't belong to them" do
          let(:issue) { Fabricate(:issue, project: project) }
          let(:resolution) { Fabricate(:resolution, issue: issue, user: admin) }

          it { is_expected.not_to be_able_to(:create, resolution) }
          it { is_expected.to be_able_to(:read, resolution) }
          it { is_expected.to be_able_to(:update, resolution) }
          it { is_expected.to be_able_to(:destroy, resolution) }
        end

        context "and resolution doesn't belong to them" do
          let(:issue) { Fabricate(:issue, project: project, user: admin) }
          let(:resolution) { Fabricate(:resolution, issue: issue) }

          it { is_expected.not_to be_able_to(:create, resolution) }
          it { is_expected.to be_able_to(:read, resolution) }
          it { is_expected.to be_able_to(:update, resolution) }
          it { is_expected.to be_able_to(:destroy, resolution) }
        end
      end

      context "when issue project is internal" do
        let(:project) { Fabricate(:internal_project) }

        context "and resolution/issue belong to them" do
          let(:issue) { Fabricate(:issue, project: project, user: admin) }
          let(:resolution) { Fabricate(:resolution, issue: issue, user: admin) }

          it { is_expected.to be_able_to(:create, resolution) }
          it { is_expected.to be_able_to(:read, resolution) }
          it { is_expected.to be_able_to(:update, resolution) }
          it { is_expected.to be_able_to(:destroy, resolution) }
        end

        context "and issue doesn't belong to them" do
          let(:issue) { Fabricate(:issue, project: project) }
          let(:resolution) { Fabricate(:resolution, issue: issue, user: admin) }

          it { is_expected.not_to be_able_to(:create, resolution) }
          it { is_expected.to be_able_to(:read, resolution) }
          it { is_expected.to be_able_to(:update, resolution) }
          it { is_expected.to be_able_to(:destroy, resolution) }
        end

        context "and resolution doesn't belong to them" do
          let(:issue) { Fabricate(:issue, project: project, user: admin) }
          let(:resolution) { Fabricate(:resolution, issue: issue) }

          it { is_expected.not_to be_able_to(:create, resolution) }
          it { is_expected.to be_able_to(:read, resolution) }
          it { is_expected.to be_able_to(:update, resolution) }
          it { is_expected.to be_able_to(:destroy, resolution) }
        end
      end

      context "when issue project is invisible" do
        let(:project) { Fabricate(:invisible_project) }

        context "and resolution/issue belong to them" do
          let(:issue) { Fabricate(:issue, project: project, user: admin) }
          let(:resolution) { Fabricate(:resolution, issue: issue, user: admin) }

          it { is_expected.not_to be_able_to(:create, resolution) }
          it { is_expected.to be_able_to(:read, resolution) }
          it { is_expected.to be_able_to(:update, resolution) }
          it { is_expected.to be_able_to(:destroy, resolution) }
        end

        context "and issue doesn't belong to them" do
          let(:issue) { Fabricate(:issue, project: project) }
          let(:resolution) { Fabricate(:resolution, issue: issue, user: admin) }

          it { is_expected.not_to be_able_to(:create, resolution) }
          it { is_expected.to be_able_to(:read, resolution) }
          it { is_expected.to be_able_to(:update, resolution) }
          it { is_expected.to be_able_to(:destroy, resolution) }
        end

        context "and resolution doesn't belong to them" do
          let(:issue) { Fabricate(:issue, project: project, user: admin) }
          let(:resolution) { Fabricate(:resolution, issue: issue) }

          it { is_expected.not_to be_able_to(:create, resolution) }
          it { is_expected.to be_able_to(:read, resolution) }
          it { is_expected.to be_able_to(:update, resolution) }
          it { is_expected.to be_able_to(:destroy, resolution) }
        end
      end
    end

    %i[reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        context "when issue is totally visible" do
          let(:project) { Fabricate(:project) }

          context "when resolution/issue belong to them" do
            let(:issue) do
              Fabricate(:issue, project: project, user: current_user)
            end
            let(:resolution) do
              Fabricate(:resolution, issue: issue, user: current_user)
            end

            it { is_expected.to be_able_to(:create, resolution) }
            it { is_expected.to be_able_to(:read, resolution) }
            it { is_expected.not_to be_able_to(:update, resolution) }
            it { is_expected.not_to be_able_to(:destroy, resolution) }
          end

          context "when resolution doesn't belong to them" do
            let(:issue) do
              Fabricate(:issue, project: project, user: current_user)
            end
            let(:resolution) { Fabricate(:resolution, issue: issue) }

            it { is_expected.not_to be_able_to(:create, resolution) }
            it { is_expected.to be_able_to(:read, resolution) }
            it { is_expected.not_to be_able_to(:update, resolution) }
            it { is_expected.not_to be_able_to(:destroy, resolution) }
          end

          context "when issue doesn't belong to them" do
            let(:issue) { Fabricate(:issue, project: project) }
            let(:resolution) { Fabricate(:resolution, issue: issue) }

            it { is_expected.not_to be_able_to(:create, resolution) }
            it { is_expected.to be_able_to(:read, resolution) }
            it { is_expected.not_to be_able_to(:update, resolution) }
            it { is_expected.not_to be_able_to(:destroy, resolution) }
          end
        end

        context "when issue project is internal" do
          let(:project) { Fabricate(:internal_project) }
          let(:issue) { Fabricate(:issue, project: project) }

          context "when resolution/issue belong to them" do
            let(:issue) do
              Fabricate(:issue, project: project, user: current_user)
            end
            let(:resolution) do
              Fabricate(:resolution, issue: issue, user: current_user)
            end

            it { is_expected.to be_able_to(:create, resolution) }
            it { is_expected.to be_able_to(:read, resolution) }
            it { is_expected.not_to be_able_to(:update, resolution) }
            it { is_expected.not_to be_able_to(:destroy, resolution) }
          end

          context "when resolution doesn't belong to them" do
            let(:issue) do
              Fabricate(:issue, project: project, user: current_user)
            end
            let(:resolution) { Fabricate(:resolution, issue: issue) }

            it { is_expected.not_to be_able_to(:create, resolution) }
            it { is_expected.to be_able_to(:read, resolution) }
            it { is_expected.not_to be_able_to(:update, resolution) }
            it { is_expected.not_to be_able_to(:destroy, resolution) }
          end

          context "when issue doesn't belong to them" do
            let(:issue) { Fabricate(:issue, project: project) }
            let(:resolution) { Fabricate(:resolution, issue: issue) }

            it { is_expected.not_to be_able_to(:create, resolution) }
            it { is_expected.to be_able_to(:read, resolution) }
            it { is_expected.not_to be_able_to(:update, resolution) }
            it { is_expected.not_to be_able_to(:destroy, resolution) }
          end
        end

        context "when issue project is invisible" do
          let(:project) { Fabricate(:invisible_project) }
          let(:issue) { Fabricate(:issue, project: project) }

          context "when resolution/issue belong to them" do
            let(:issue) do
              Fabricate(:issue, project: project, user: current_user)
            end
            let(:resolution) do
              Fabricate(:resolution, issue: issue, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, resolution) }
            it { is_expected.to be_able_to(:read, resolution) }
            it { is_expected.not_to be_able_to(:update, resolution) }
            it { is_expected.not_to be_able_to(:destroy, resolution) }
          end

          context "when resolution doesn't belong to them" do
            let(:issue) do
              Fabricate(:issue, project: project, user: current_user)
            end
            let(:resolution) { Fabricate(:resolution, issue: issue) }

            it { is_expected.not_to be_able_to(:create, resolution) }
            it { is_expected.to be_able_to(:read, resolution) }
            it { is_expected.not_to be_able_to(:update, resolution) }
            it { is_expected.not_to be_able_to(:destroy, resolution) }
          end

          context "when issue doesn't belong to them" do
            let(:issue) { Fabricate(:issue, project: project) }
            let(:resolution) { Fabricate(:resolution, issue: issue) }

            it { is_expected.not_to be_able_to(:create, resolution) }
            it { is_expected.to be_able_to(:read, resolution) }
            it { is_expected.not_to be_able_to(:update, resolution) }
            it { is_expected.not_to be_able_to(:destroy, resolution) }
          end
        end
      end
    end

    %i[worker].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        context "when issue is totally visible" do
          let(:project) { Fabricate(:project) }

          context "when resolution/issue belong to them" do
            let(:issue) do
              Fabricate(:issue, project: project, user: current_user)
            end
            let(:resolution) do
              Fabricate(:resolution, issue: issue, user: current_user)
            end

            it { is_expected.to be_able_to(:create, resolution) }
            it { is_expected.to be_able_to(:read, resolution) }
            it { is_expected.not_to be_able_to(:update, resolution) }
            it { is_expected.not_to be_able_to(:destroy, resolution) }
          end

          context "when resolution doesn't belong to them" do
            let(:issue) do
              Fabricate(:issue, project: project, user: current_user)
            end
            let(:resolution) { Fabricate(:resolution, issue: issue) }

            it { is_expected.not_to be_able_to(:create, resolution) }
            it { is_expected.to be_able_to(:read, resolution) }
            it { is_expected.not_to be_able_to(:update, resolution) }
            it { is_expected.not_to be_able_to(:destroy, resolution) }
          end

          context "when issue doesn't belong to them" do
            let(:issue) { Fabricate(:issue, project: project) }
            let(:resolution) { Fabricate(:resolution, issue: issue) }

            it { is_expected.not_to be_able_to(:create, resolution) }
            it { is_expected.to be_able_to(:read, resolution) }
            it { is_expected.not_to be_able_to(:update, resolution) }
            it { is_expected.not_to be_able_to(:destroy, resolution) }
          end
        end

        context "when issue project is internal" do
          let(:project) { Fabricate(:internal_project) }
          let(:issue) { Fabricate(:issue, project: project) }

          context "when resolution/issue belong to them" do
            let(:issue) do
              Fabricate(:issue, project: project, user: current_user)
            end
            let(:resolution) do
              Fabricate(:resolution, issue: issue, user: current_user)
            end

            it { is_expected.to be_able_to(:create, resolution) }
            it { is_expected.to be_able_to(:read, resolution) }
            it { is_expected.not_to be_able_to(:update, resolution) }
            it { is_expected.not_to be_able_to(:destroy, resolution) }
          end

          context "when resolution doesn't belong to them" do
            let(:issue) do
              Fabricate(:issue, project: project, user: current_user)
            end
            let(:resolution) { Fabricate(:resolution, issue: issue) }

            it { is_expected.not_to be_able_to(:create, resolution) }
            it { is_expected.to be_able_to(:read, resolution) }
            it { is_expected.not_to be_able_to(:update, resolution) }
            it { is_expected.not_to be_able_to(:destroy, resolution) }
          end

          context "when issue doesn't belong to them" do
            let(:issue) { Fabricate(:issue, project: project) }
            let(:resolution) { Fabricate(:resolution, issue: issue) }

            it { is_expected.not_to be_able_to(:create, resolution) }
            it { is_expected.to be_able_to(:read, resolution) }
            it { is_expected.not_to be_able_to(:update, resolution) }
            it { is_expected.not_to be_able_to(:destroy, resolution) }
          end
        end

        context "when issue project is invisible" do
          let(:project) { Fabricate(:invisible_project) }
          let(:issue) { Fabricate(:issue, project: project) }

          context "when resolution/issue belong to them" do
            let(:issue) do
              Fabricate(:issue, project: project, user: current_user)
            end
            let(:resolution) do
              Fabricate(:resolution, issue: issue, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, resolution) }
            it { is_expected.not_to be_able_to(:read, resolution) }
            it { is_expected.not_to be_able_to(:update, resolution) }
            it { is_expected.not_to be_able_to(:destroy, resolution) }
          end

          context "when resolution doesn't belong to them" do
            let(:issue) do
              Fabricate(:issue, project: project, user: current_user)
            end
            let(:resolution) { Fabricate(:resolution, issue: issue) }

            it { is_expected.not_to be_able_to(:create, resolution) }
            it { is_expected.not_to be_able_to(:read, resolution) }
            it { is_expected.not_to be_able_to(:update, resolution) }
            it { is_expected.not_to be_able_to(:destroy, resolution) }
          end

          context "when issue doesn't belong to them" do
            let(:issue) { Fabricate(:issue, project: project) }
            let(:resolution) { Fabricate(:resolution, issue: issue) }

            it { is_expected.not_to be_able_to(:create, resolution) }
            it { is_expected.not_to be_able_to(:read, resolution) }
            it { is_expected.not_to be_able_to(:update, resolution) }
            it { is_expected.not_to be_able_to(:destroy, resolution) }
          end
        end
      end
    end

    %i[reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        subject(:ability) { Ability.new(current_user) }

        context "when issue is totally visible" do
          let(:project) { Fabricate(:project) }

          context "when resolution/issue belong to them" do
            let(:issue) do
              Fabricate(:issue, project: project, user: current_user)
            end
            let(:resolution) do
              Fabricate(:resolution, issue: issue, user: current_user)
            end

            it { is_expected.to be_able_to(:create, resolution) }
            it { is_expected.to be_able_to(:read, resolution) }
            it { is_expected.not_to be_able_to(:update, resolution) }
            it { is_expected.not_to be_able_to(:destroy, resolution) }
          end

          context "when resolution doesn't belong to them" do
            let(:issue) do
              Fabricate(:issue, project: project, user: current_user)
            end
            let(:resolution) { Fabricate(:resolution, issue: issue) }

            it { is_expected.not_to be_able_to(:create, resolution) }
            it { is_expected.to be_able_to(:read, resolution) }
            it { is_expected.not_to be_able_to(:update, resolution) }
            it { is_expected.not_to be_able_to(:destroy, resolution) }
          end

          context "when issue doesn't belong to them" do
            let(:issue) { Fabricate(:issue, project: project) }
            let(:resolution) { Fabricate(:resolution, issue: issue) }

            it { is_expected.not_to be_able_to(:create, resolution) }
            it { is_expected.to be_able_to(:read, resolution) }
            it { is_expected.not_to be_able_to(:update, resolution) }
            it { is_expected.not_to be_able_to(:destroy, resolution) }
          end
        end

        context "when issue project is internal" do
          let(:project) { Fabricate(:internal_project) }
          let(:issue) { Fabricate(:issue, project: project) }

          context "when resolution/issue belong to them" do
            let(:issue) do
              Fabricate(:issue, project: project, user: current_user)
            end
            let(:resolution) do
              Fabricate(:resolution, issue: issue, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, resolution) }
            it { is_expected.not_to be_able_to(:read, resolution) }
            it { is_expected.not_to be_able_to(:update, resolution) }
            it { is_expected.not_to be_able_to(:destroy, resolution) }
          end

          context "when resolution doesn't belong to them" do
            let(:issue) do
              Fabricate(:issue, project: project, user: current_user)
            end
            let(:resolution) { Fabricate(:resolution, issue: issue) }

            it { is_expected.not_to be_able_to(:create, resolution) }
            it { is_expected.not_to be_able_to(:read, resolution) }
            it { is_expected.not_to be_able_to(:update, resolution) }
            it { is_expected.not_to be_able_to(:destroy, resolution) }
          end

          context "when issue doesn't belong to them" do
            let(:issue) { Fabricate(:issue, project: project) }
            let(:resolution) { Fabricate(:resolution, issue: issue) }

            it { is_expected.not_to be_able_to(:create, resolution) }
            it { is_expected.not_to be_able_to(:read, resolution) }
            it { is_expected.not_to be_able_to(:update, resolution) }
            it { is_expected.not_to be_able_to(:destroy, resolution) }
          end
        end

        context "when issue project is invisible" do
          let(:project) { Fabricate(:invisible_project) }
          let(:issue) { Fabricate(:issue, project: project) }

          context "when resolution/issue belong to them" do
            let(:issue) do
              Fabricate(:issue, project: project, user: current_user)
            end
            let(:resolution) do
              Fabricate(:resolution, issue: issue, user: current_user)
            end

            it { is_expected.not_to be_able_to(:create, resolution) }
            it { is_expected.not_to be_able_to(:read, resolution) }
            it { is_expected.not_to be_able_to(:update, resolution) }
            it { is_expected.not_to be_able_to(:destroy, resolution) }
          end

          context "when resolution doesn't belong to them" do
            let(:issue) do
              Fabricate(:issue, project: project, user: current_user)
            end
            let(:resolution) { Fabricate(:resolution, issue: issue) }

            it { is_expected.not_to be_able_to(:create, resolution) }
            it { is_expected.not_to be_able_to(:read, resolution) }
            it { is_expected.not_to be_able_to(:update, resolution) }
            it { is_expected.not_to be_able_to(:destroy, resolution) }
          end

          context "when issue doesn't belong to them" do
            let(:issue) { Fabricate(:issue, project: project) }
            let(:resolution) { Fabricate(:resolution, issue: issue) }

            it { is_expected.not_to be_able_to(:create, resolution) }
            it { is_expected.not_to be_able_to(:read, resolution) }
            it { is_expected.not_to be_able_to(:update, resolution) }
            it { is_expected.not_to be_able_to(:destroy, resolution) }
          end
        end
      end
    end
  end
end
