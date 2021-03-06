# frozen_string_literal: true

require "rails_helper"

RSpec.describe IssuesController, type: :controller do
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:issue_type) { Fabricate(:issue_type) }
  let(:user) { Fabricate(:user_reporter) }
  let(:admin) { Fabricate(:user_admin) }

  let(:valid_attributes) do
    { issue_type_id: issue_type.id, summary: "Summary",
      description: "Description" }
  end

  let(:invalid_attributes) { { summary: "" } }

  describe "GET #index" do
    context "for an admin" do
      before { sign_in(Fabricate(:user_admin)) }

      context "when category is invisible and internal" do
        let(:category) do
          Fabricate(:category, visible: false, internal: true)
        end
        let(:project) { Fabricate(:project, category: category) }

        it "returns a success response" do
          Fabricate(:issue, project: project)
          get :index, params: { category_id: category.to_param }
          expect(response).to be_successful
        end
      end

      context "when project is invisible and internal" do
        let(:project) do
          Fabricate(:project, category: category, visible: false,
                              internal: true)
        end

        it "returns a success response" do
          Fabricate(:issue, project: project)
          get :index, params: { project_id: project.to_param }
          expect(response).to be_successful
        end
      end

      context "when user" do
        context "is an employee" do
          it "returns a success response" do
            Fabricate(:issue, user: user)
            get :index, params: { user_id: user.to_param }
            expect(response).to be_successful
          end
        end

        context "is not an employee" do
          before { user.update employee_type: nil }

          it "returns a success response" do
            Fabricate(:issue, user: user)
            get :index, params: { user_id: user.to_param }
            expect(response).to be_successful
          end
        end
      end
    end

    context "for a reviewer" do
      before { sign_in(Fabricate(:user_reviewer)) }

      context "when category is invisible and internal" do
        let(:category) do
          Fabricate(:category, visible: false, internal: true)
        end
        let(:project) { Fabricate(:project, category: category) }

        it "returns a success response" do
          Fabricate(:issue, project: project)
          get :index, params: { category_id: category.to_param }
          expect(response).to be_successful
        end
      end

      context "when project is invisible and internal" do
        let(:project) do
          Fabricate(:project, category: category, visible: false,
                              internal: true)
        end

        it "returns a success response" do
          Fabricate(:issue, project: project)
          get :index, params: { project_id: project.to_param }
          expect(response).to be_successful
        end
      end

      context "when user" do
        context "is an employee" do
          it "returns a success response" do
            Fabricate(:issue, user: user)
            get :index, params: { user_id: user.to_param }
            expect(response).to be_successful
          end
        end

        context "is not an employee" do
          before { user.update employee_type: nil }

          it "should be unauthorized" do
            Fabricate(:issue, user: user)
            get :index, params: { user_id: user.to_param }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end

    %w[worker].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        before { sign_in(current_user) }

        context "when category" do
          context "is visible" do
            context "and external" do
              let(:category) do
                Fabricate(:category, visible: true, internal: false)
              end
              let(:project) { Fabricate(:project, category: category) }

              it "returns a success response" do
                Fabricate(:issue, project: project)
                Fabricate(:issue, project: project, user: current_user)
                get :index, params: { category_id: category.to_param }
                expect(response).to be_successful
              end

              context "and internal" do
                let(:category) do
                  Fabricate(:category, visible: true, internal: true)
                end
                let(:project) { Fabricate(:project, category: category) }

                it "returns a success response" do
                  Fabricate(:issue, project: project)
                  Fabricate(:issue, project: project, user: current_user)
                  get :index, params: { category_id: category.to_param }
                  expect(response).to be_successful
                end
              end
            end
          end

          context "is invisible" do
            context "and external" do
              let(:category) do
                Fabricate(:category, visible: false, internal: false)
              end
              let(:project) { Fabricate(:project, category: category) }

              it "should be unauthorized" do
                Fabricate(:issue, project: project)
                Fabricate(:issue, project: project, user: current_user)
                get :index, params: { category_id: category.to_param }
                expect_to_be_unauthorized(response)
              end

              context "and internal" do
                let(:category) do
                  Fabricate(:category, visible: false, internal: true)
                end
                let(:project) { Fabricate(:project, category: category) }

                it "should be unauthorized" do
                  Fabricate(:issue, project: project)
                  Fabricate(:issue, project: project, user: current_user)
                  get :index, params: { category_id: category.to_param }
                  expect_to_be_unauthorized(response)
                end
              end
            end
          end
        end

        context "when project" do
          context "has a visible category" do
            context "and external" do
              let(:category) do
                Fabricate(:category, visible: true, internal: false)
              end

              context "and project is visible" do
                context "and external" do
                  let(:project) do
                    Fabricate(:project, category: category, visible: true,
                                        internal: false)
                  end

                  it "returns a success response" do
                    Fabricate(:issue, project: project)
                    Fabricate(:issue, project: project, user: current_user)
                    get :index, params: { project_id: project.to_param }
                    expect(response).to be_successful
                  end
                end

                context "and internal" do
                  let(:project) do
                    Fabricate(:project, category: category, visible: true,
                                        internal: true)
                  end

                  it "returns a success response" do
                    Fabricate(:issue, project: project)
                    Fabricate(:issue, project: project, user: current_user)
                    get :index, params: { project_id: project.to_param }
                    expect(response).to be_successful
                  end
                end
              end

              context "and project is invisible" do
                context "and external" do
                  let(:project) do
                    Fabricate(:project, category: category, visible: false,
                                        internal: false)
                  end

                  it "should be unauthorized" do
                    Fabricate(:issue, project: project)
                    Fabricate(:issue, project: project, user: current_user)
                    get :index, params: { project_id: project.to_param }
                    expect_to_be_unauthorized(response)
                  end
                end

                context "and internal" do
                  let(:project) do
                    Fabricate(:project, category: category, visible: false,
                                        internal: true)
                  end

                  it "should be unauthorized" do
                    Fabricate(:issue, project: project)
                    Fabricate(:issue, project: project, user: current_user)
                    get :index, params: { project_id: project.to_param }
                    expect_to_be_unauthorized(response)
                  end
                end
              end
            end

            context "and internal" do
              let(:category) do
                Fabricate(:category, visible: true, internal: true)
              end

              context "and project is visible" do
                context "and external" do
                  let(:project) do
                    Fabricate(:project, category: category, visible: true,
                                        internal: false)
                  end

                  it "returns a success response" do
                    Fabricate(:issue, project: project)
                    Fabricate(:issue, project: project, user: current_user)
                    get :index, params: { project_id: project.to_param }
                    expect(response).to be_successful
                  end
                end

                context "and internal" do
                  let(:project) do
                    Fabricate(:project, category: category, visible: true,
                                        internal: true)
                  end

                  it "returns a success response" do
                    Fabricate(:issue, project: project)
                    Fabricate(:issue, project: project, user: current_user)
                    get :index, params: { project_id: project.to_param }
                    expect(response).to be_successful
                  end
                end
              end

              context "and project is invisible" do
                context "and external" do
                  let(:project) do
                    Fabricate(:project, category: category, visible: false,
                                        internal: false)
                  end

                  it "should be unauthorized" do
                    Fabricate(:issue, project: project)
                    Fabricate(:issue, project: project, user: current_user)
                    get :index, params: { project_id: project.to_param }
                    expect_to_be_unauthorized(response)
                  end
                end

                context "and internal" do
                  let(:project) do
                    Fabricate(:project, category: category, visible: false,
                                        internal: true)
                  end

                  it "should be unauthorized" do
                    Fabricate(:issue, project: project)
                    Fabricate(:issue, project: project, user: current_user)
                    get :index, params: { project_id: project.to_param }
                    expect_to_be_unauthorized(response)
                  end
                end
              end
            end
          end

          context "is invisible" do
            let(:category) do
              Fabricate(:category, visible: false, internal: false)
            end
            let(:project) do
              Fabricate(:project, category: category, visible: true,
                                  internal: false)
            end

            it "should be unauthorized" do
              Fabricate(:issue, project: project)
              Fabricate(:issue, project: project, user: current_user)
              get :index, params: { project_id: project.to_param }
              expect_to_be_unauthorized(response)
            end
          end
        end

        context "when user" do
          context "is an employee" do
            it "returns a success response" do
              Fabricate(:issue, user: user)
              get :index, params: { user_id: user.to_param }
              expect(response).to be_successful
            end
          end

          context "is not an employee" do
            before { user.update employee_type: nil }

            it "should be unauthorized" do
              Fabricate(:issue, user: user)
              get :index, params: { user_id: user.to_param }
              expect_to_be_unauthorized(response)
            end
          end
        end
      end
    end

    %w[reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        before { sign_in(current_user) }

        context "when category" do
          context "is visible" do
            context "and external" do
              let(:category) do
                Fabricate(:category, visible: true, internal: false)
              end
              let(:project) { Fabricate(:project, category: category) }

              it "returns a success response" do
                Fabricate(:issue, project: project)
                Fabricate(:issue, project: project, user: current_user)
                get :index, params: { category_id: category.to_param }
                expect(response).to be_successful
              end

              context "and internal" do
                let(:category) do
                  Fabricate(:category, visible: true, internal: true)
                end
                let(:project) { Fabricate(:project, category: category) }

                it "should be unauthorized" do
                  Fabricate(:issue, project: project)
                  Fabricate(:issue, project: project, user: current_user)
                  get :index, params: { category_id: category.to_param }
                  expect_to_be_unauthorized(response)
                end
              end
            end
          end

          context "is invisible" do
            context "and external" do
              let(:category) do
                Fabricate(:category, visible: false, internal: false)
              end
              let(:project) { Fabricate(:project, category: category) }

              it "should be unauthorized" do
                Fabricate(:issue, project: project)
                Fabricate(:issue, project: project, user: current_user)
                get :index, params: { category_id: category.to_param }
                expect_to_be_unauthorized(response)
              end

              context "and internal" do
                let(:category) do
                  Fabricate(:category, visible: false, internal: true)
                end
                let(:project) { Fabricate(:project, category: category) }

                it "should be unauthorized" do
                  Fabricate(:issue, project: project)
                  Fabricate(:issue, project: project, user: current_user)
                  get :index, params: { category_id: category.to_param }
                  expect_to_be_unauthorized(response)
                end
              end
            end
          end
        end

        context "when project" do
          context "has a visible category" do
            context "and external" do
              let(:category) do
                Fabricate(:category, visible: true, internal: false)
              end

              context "and project is visible" do
                context "and external" do
                  let(:project) do
                    Fabricate(:project, category: category, visible: true,
                                        internal: false)
                  end

                  it "returns a success response" do
                    Fabricate(:issue, project: project)
                    Fabricate(:issue, project: project, user: current_user)
                    get :index, params: { project_id: project.to_param }
                    expect(response).to be_successful
                  end
                end

                context "and internal" do
                  let(:project) do
                    Fabricate(:project, category: category, visible: true,
                                        internal: true)
                  end

                  it "should be unauthorized" do
                    Fabricate(:issue, project: project)
                    Fabricate(:issue, project: project, user: current_user)
                    get :index, params: { project_id: project.to_param }
                    expect_to_be_unauthorized(response)
                  end
                end
              end

              context "and project is invisible" do
                context "and external" do
                  let(:project) do
                    Fabricate(:project, category: category, visible: false,
                                        internal: false)
                  end

                  it "should be unauthorized" do
                    Fabricate(:issue, project: project)
                    Fabricate(:issue, project: project, user: current_user)
                    get :index, params: { project_id: project.to_param }
                    expect_to_be_unauthorized(response)
                  end
                end

                context "and internal" do
                  let(:project) do
                    Fabricate(:project, category: category, visible: false,
                                        internal: true)
                  end

                  it "should be unauthorized" do
                    Fabricate(:issue, project: project)
                    Fabricate(:issue, project: project, user: current_user)
                    get :index, params: { project_id: project.to_param }
                    expect_to_be_unauthorized(response)
                  end
                end
              end
            end

            context "and internal" do
              let(:category) do
                Fabricate(:category, visible: true, internal: true)
              end

              context "and project is visible" do
                context "and external" do
                  let(:project) do
                    Fabricate(:project, category: category, visible: true,
                                        internal: false)
                  end

                  it "should be unauthorized" do
                    Fabricate(:issue, project: project)
                    Fabricate(:issue, project: project, user: current_user)
                    get :index, params: { project_id: project.to_param }
                    expect_to_be_unauthorized(response)
                  end
                end

                context "and internal" do
                  let(:project) do
                    Fabricate(:project, category: category, visible: true,
                                        internal: true)
                  end

                  it "should be unauthorized" do
                    Fabricate(:issue, project: project)
                    Fabricate(:issue, project: project, user: current_user)
                    get :index, params: { project_id: project.to_param }
                    expect_to_be_unauthorized(response)
                  end
                end
              end

              context "and project is invisible" do
                context "and external" do
                  let(:project) do
                    Fabricate(:project, category: category, visible: false,
                                        internal: false)
                  end

                  it "should be unauthorized" do
                    Fabricate(:issue, project: project)
                    Fabricate(:issue, project: project, user: current_user)
                    get :index, params: { project_id: project.to_param }
                    expect_to_be_unauthorized(response)
                  end
                end

                context "and internal" do
                  let(:project) do
                    Fabricate(:project, category: category, visible: false,
                                        internal: true)
                  end

                  it "should be unauthorized" do
                    Fabricate(:issue, project: project)
                    Fabricate(:issue, project: project, user: current_user)
                    get :index, params: { project_id: project.to_param }
                    expect_to_be_unauthorized(response)
                  end
                end
              end
            end
          end

          context "is invisible" do
            let(:category) do
              Fabricate(:category, visible: false, internal: false)
            end
            let(:project) do
              Fabricate(:project, category: category, visible: true,
                                  internal: false)
            end

            it "should be unauthorized" do
              Fabricate(:issue, project: project)
              Fabricate(:issue, project: project, user: current_user)
              get :index, params: { project_id: project.to_param }
              expect_to_be_unauthorized(response)
            end
          end
        end

        context "when user" do
          context "is an employee" do
            it "returns a success response" do
              Fabricate(:issue, user: user)
              get :index, params: { user_id: user.to_param }
              expect(response).to be_successful
            end
          end

          context "is not an employee" do
            before { user.update employee_type: nil }

            it "should be unauthorized" do
              Fabricate(:issue, user: user)
              get :index, params: { user_id: user.to_param }
              expect_to_be_unauthorized(response)
            end
          end
        end
      end
    end
  end

  describe "GET #show" do
    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when category/project are invisible and internal" do
          let(:category) do
            Fabricate(:category, visible: false, internal: true)
          end
          let(:project) do
            Fabricate(:project, category: category, visible: false,
                                internal: true)
          end

          context "when someone else's issue" do
            it "returns a success response" do
              issue = Fabricate(:issue, project: project)
              get :show, params: { id: issue.to_param }
              expect(response).to be_successful
            end
          end

          context "when their issue" do
            it "returns a success response" do
              issue = Fabricate(:issue, project: project, user: current_user)
              get :show, params: { id: issue.to_param }
              expect(response).to be_successful
            end
          end
        end

        context "when task_id" do
          context "for a html request" do
            it "returns a success response" do
              issue = Fabricate(:issue, project: project)
              task = Fabricate(:task, project: project, issue: issue)
              get :show, params: { id: issue.to_param, task_id: task.to_param }
              expect(response).to be_successful
            end
          end

          context "for a js request" do
            it "returns a success response" do
              issue = Fabricate(:issue, project: project)
              task = Fabricate(:task, project: project, issue: issue)
              get :show, params: { id: issue.to_param, task_id: task.to_param },
                         xhr: true
              expect(response).to be_successful
            end
          end
        end
      end
    end

    %w[worker].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when category is visible" do
          context "and external" do
            let(:category) do
              Fabricate(:category, visible: true, internal: false)
            end

            context "while project is visible" do
              context "and external" do
                let(:project) do
                  Fabricate(:project, category: category, visible: true,
                                      internal: false)
                end

                context "when someone else's issue" do
                  it "returns a success response" do
                    issue = Fabricate(:issue, project: project)
                    get :show, params: { id: issue.to_param }
                    expect(response).to be_successful
                  end
                end

                context "when their issue" do
                  it "returns a success response" do
                    issue = Fabricate(:issue, project: project,
                                              user: current_user)
                    get :show, params: { id: issue.to_param }
                    expect(response).to be_successful
                  end
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, visible: true,
                                      internal: true)
                end

                context "when someone else's issue" do
                  it "returns a success response" do
                    issue = Fabricate(:issue, project: project)
                    get :show, params: { id: issue.to_param }
                    expect(response).to be_successful
                  end
                end

                context "when their issue" do
                  it "returns a success response" do
                    issue = Fabricate(:issue, project: project,
                                              user: current_user)
                    get :show, params: { id: issue.to_param }
                    expect(response).to be_successful
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

                context "when someone else's issue" do
                  it "should be unauthorized" do
                    issue = Fabricate(:issue, project: project)
                    get :show, params: { id: issue.to_param }
                    expect_to_be_unauthorized(response)
                  end
                end

                context "when their issue" do
                  it "should be unauthorized" do
                    issue = Fabricate(:issue, project: project)
                    get :show, params: { id: issue.to_param }
                    expect_to_be_unauthorized(response)
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
                let(:project) do
                  Fabricate(:project, category: category, visible: true,
                                      internal: false)
                end

                context "when someone else's issue" do
                  it "returns a success response" do
                    issue = Fabricate(:issue, project: project)
                    get :show, params: { id: issue.to_param }
                    expect(response).to be_successful
                  end
                end

                context "when their issue" do
                  it "returns a success response" do
                    issue = Fabricate(:issue, project: project,
                                              user: current_user)
                    get :show, params: { id: issue.to_param }
                    expect(response).to be_successful
                  end
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, visible: true,
                                      internal: true)
                end

                context "when someone else's issue" do
                  it "returns a success response" do
                    issue = Fabricate(:issue, project: project)
                    get :show, params: { id: issue.to_param }
                    expect(response).to be_successful
                  end
                end

                context "when their issue" do
                  it "returns a success response" do
                    issue = Fabricate(:issue, project: project,
                                              user: current_user)
                    get :show, params: { id: issue.to_param }
                    expect(response).to be_successful
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

                context "when someone else's issue" do
                  it "should be unauthorized" do
                    issue = Fabricate(:issue, project: project)
                    get :show, params: { id: issue.to_param }
                    expect_to_be_unauthorized(response)
                  end
                end

                context "when their issue" do
                  it "should be unauthorized" do
                    issue = Fabricate(:issue, project: project)
                    get :show, params: { id: issue.to_param }
                    expect_to_be_unauthorized(response)
                  end
                end
              end
            end
          end
        end

        context "when category is invisible" do
          context "and external" do
            let(:category) do
              Fabricate(:category, visible: false, internal: false)
            end

            context "while project is visible" do
              context "and external" do
                let(:project) do
                  Fabricate(:project, category: category, visible: true,
                                      internal: false)
                end

                context "when someone else's issue" do
                  it "should be unauthorized" do
                    issue = Fabricate(:issue, project: project)
                    get :show, params: { id: issue.to_param }
                    expect_to_be_unauthorized(response)
                  end
                end

                context "when their issue" do
                  it "should be unauthorized" do
                    issue = Fabricate(:issue, project: project)
                    get :show, params: { id: issue.to_param }
                    expect_to_be_unauthorized(response)
                  end
                end
              end
            end
          end
        end

        context "when task_id" do
          context "for a html request" do
            it "returns a success response" do
              issue = Fabricate(:issue, project: project)
              task = Fabricate(:task, project: project, issue: issue)
              get :show, params: { id: issue.to_param, task_id: task.to_param }
              expect(response).to be_successful
            end
          end

          context "for a js request" do
            it "returns a success response" do
              issue = Fabricate(:issue, project: project)
              task = Fabricate(:task, project: project, issue: issue)
              get :show, params: { id: issue.to_param, task_id: task.to_param },
                         xhr: true
              expect(response).to be_successful
            end
          end
        end
      end
    end

    %w[reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when category is visible" do
          context "and external" do
            let(:category) do
              Fabricate(:category, visible: true, internal: false)
            end

            context "while project is visible" do
              context "and external" do
                let(:project) do
                  Fabricate(:project, category: category, visible: true,
                                      internal: false)
                end

                context "when someone else's issue" do
                  it "returns a success response" do
                    issue = Fabricate(:issue, project: project)
                    get :show, params: { id: issue.to_param }
                    expect(response).to be_successful
                  end
                end

                context "when their issue" do
                  it "returns a success response" do
                    issue = Fabricate(:issue, project: project,
                                              user: current_user)
                    get :show, params: { id: issue.to_param }
                    expect(response).to be_successful
                  end
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, visible: true,
                                      internal: true)
                end

                context "when someone else's issue" do
                  it "should be unauthorized" do
                    issue = Fabricate(:issue, project: project)
                    get :show, params: { id: issue.to_param }
                    expect_to_be_unauthorized(response)
                  end
                end

                context "when their issue" do
                  it "should be unauthorized" do
                    issue = Fabricate(:issue, project: project)
                    get :show, params: { id: issue.to_param }
                    expect_to_be_unauthorized(response)
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

                context "when someone else's issue" do
                  it "should be unauthorized" do
                    issue = Fabricate(:issue, project: project)
                    get :show, params: { id: issue.to_param }
                    expect_to_be_unauthorized(response)
                  end
                end

                context "when their issue" do
                  it "should be unauthorized" do
                    issue = Fabricate(:issue, project: project)
                    get :show, params: { id: issue.to_param }
                    expect_to_be_unauthorized(response)
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
                let(:project) do
                  Fabricate(:project, category: category, visible: true,
                                      internal: false)
                end

                context "when someone else's issue" do
                  it "should be unauthorized" do
                    issue = Fabricate(:issue, project: project)
                    get :show, params: { id: issue.to_param }
                    expect_to_be_unauthorized(response)
                  end
                end

                context "when their issue" do
                  it "should be unauthorized" do
                    issue = Fabricate(:issue, project: project)
                    get :show, params: { id: issue.to_param }
                    expect_to_be_unauthorized(response)
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

                context "when someone else's issue" do
                  it "should be unauthorized" do
                    issue = Fabricate(:issue, project: project)
                    get :show, params: { id: issue.to_param }
                    expect_to_be_unauthorized(response)
                  end
                end

                context "when their issue" do
                  it "should be unauthorized" do
                    issue = Fabricate(:issue, project: project)
                    get :show, params: { id: issue.to_param }
                    expect_to_be_unauthorized(response)
                  end
                end
              end
            end
          end
        end

        context "when category is invisible" do
          context "and external" do
            let(:category) do
              Fabricate(:category, visible: false, internal: false)
            end

            context "while project is visible" do
              context "and external" do
                let(:project) do
                  Fabricate(:project, category: category, visible: true,
                                      internal: false)
                end

                context "when someone else's issue" do
                  it "should be unauthorized" do
                    issue = Fabricate(:issue, project: project)
                    get :show, params: { id: issue.to_param }
                    expect_to_be_unauthorized(response)
                  end
                end

                context "when their issue" do
                  it "should be unauthorized" do
                    issue = Fabricate(:issue, project: project)
                    get :show, params: { id: issue.to_param }
                    expect_to_be_unauthorized(response)
                  end
                end
              end
            end
          end
        end

        context "when task_id" do
          context "for a html request" do
            it "returns a success response" do
              issue = Fabricate(:issue, project: project)
              task = Fabricate(:task, project: project, issue: issue)
              get :show, params: { id: issue.to_param, task_id: task.to_param }
              expect(response).to be_successful
            end
          end

          context "for a js request" do
            it "returns a success response" do
              issue = Fabricate(:issue, project: project)
              task = Fabricate(:task, project: project, issue: issue)
              get :show, params: { id: issue.to_param, task_id: task.to_param },
                         xhr: true
              expect(response).to be_successful
            end
          end
        end
      end
    end
  end

  describe "GET #new" do
    context "for an admin" do
      before { sign_in(admin) }

      context "when an IssueType and a User" do
        before do
          Fabricate(:issue_type)
          Fabricate(:user_reporter)
        end

        it "returns a success response" do
          get :new, params: { category_id: category.to_param,
                              project_id: project.to_param }
          expect(response).to be_successful
        end
      end

      context "when no IssueTypes" do
        before { Fabricate(:user_reporter) }

        it "redirects to issue_types_url" do
          get :new, params: { category_id: category.to_param,
                              project_id: project.to_param }
          expect(response).to redirect_to(issue_types_url)
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        before { sign_in(Fabricate("user_#{employee_type.downcase}")) }

        context "when an IssueType and a User" do
          before do
            Fabricate(:issue_type)
            Fabricate(:user_reporter)
          end

          it "returns a success response" do
            get :new, params: { category_id: category.to_param,
                                project_id: project.to_param }
            expect(response).to be_successful
          end
        end

        context "when no IssueTypes" do
          before { Fabricate(:user_reporter) }

          it "redirects to project" do
            get :new, params: { category_id: category.to_param,
                                project_id: project.to_param }
            expect(response).to redirect_to(root_url)
          end
        end
      end
    end
  end

  describe "GET #edit" do
    context "for an admin" do
      before { sign_in(admin) }

      context "for their own Issue" do
        it "returns a success response" do
          issue = Fabricate(:issue, project: project, user: admin)
          get :edit, params: { id: issue.to_param }
          expect(response).to be_successful
        end
      end

      context "for someone else's Issue" do
        it "returns a success response" do
          issue = Fabricate(:issue, project: project)
          get :edit, params: { id: issue.to_param }
          expect(response).to be_successful
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        context "for their own Issue" do
          it "returns a success response" do
            issue = Fabricate(:issue, project: project, user: current_user)
            get :edit, params: { id: issue.to_param }
            expect(response).to be_successful
          end
        end

        context "for someone else's Issue" do
          it "should be unauthorized" do
            issue = Fabricate(:issue, project: project)
            get :edit, params: { id: issue.to_param }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end
  end

  describe "POST #create" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "with valid params" do
          it "creates a new Issue" do
            expect do
              post :create, params: { project_id: project.to_param,
                                      issue: valid_attributes }
            end.to change(current_user.issues, :count).by(1)
          end

          it "sets new Issue status as 'open'" do
            post :create, params: { project_id: project.to_param,
                                    issue: valid_attributes }
            issue = Issue.last
            expect(issue).not_to be_nil
            expect(issue.status).to eq("open")
          end

          it "creates a new IssueSubscription" do
            expect do
              post :create, params: { project_id: project.to_param,
                                      issue: valid_attributes }
            end.to change(current_user.issue_subscriptions, :count).by(1)
          end

          it "redirects to the created issue" do
            post :create, params: { project_id: project.to_param,
                                    issue: valid_attributes }
            url = issue_path(Issue.last)
            expect(response).to redirect_to(url)
          end

          context "when someone subscribed to category" do
            let(:user) { Fabricate(:user_reviewer) }

            before do
              Fabricate(:category_issues_subscription, user: user,
                                                       category: category)
            end

            it "creates a new IssueSubscription" do
              expect do
                post :create, params: { project_id: project.to_param,
                                        issue: valid_attributes }
              end.to change(user.issue_subscriptions, :count).by(1)
            end

            it "sends email to subscribers" do
              expect do
                post :create, params: { project_id: project.to_param,
                                        issue: valid_attributes }
              end.to(have_enqueued_job.with do |mailer, action, time, options|
                expect(mailer).to eq("IssueMailer")
                expect(action).to eq("new")
                expect(time).to eq("deliver_now")
                expect(options)
                  .to eq(args: [], params: { issue: Issue.last, user: user })
              end)
            end
          end

          context "when someone subscribed to project" do
            let(:user) { Fabricate(:user_reviewer) }

            before do
              Fabricate(:project_issues_subscription, user: user,
                                                      project: project)
            end

            it "creates a new IssueSubscription" do
              expect do
                post :create, params: { project_id: project.to_param,
                                        issue: valid_attributes }
              end.to change(user.issue_subscriptions, :count).by(1)
            end
          end
        end

        context "with invalid params" do
          it "doesn't create a new Issue" do
            expect do
              post :create, params: { project_id: project.to_param,
                                      issue: invalid_attributes }
            end.not_to change(Issue, :count)
          end

          it "returns a success response ('new' template)" do
            post :create, params: { project_id: project.to_param,
                                    issue: invalid_attributes }
            expect(response).to be_successful
          end
        end
      end
    end
  end

  describe "PUT #update" do
    let(:new_attributes) { { summary: "New Summary" } }

    context "for an admin" do
      before { sign_in(admin) }

      context "for their own Issue" do
        context "with valid params" do
          it "updates the requested issue summary" do
            issue = Fabricate(:issue, project: project, user: admin)

            expect do
              put :update, params: { id: issue.to_param,
                                     issue: new_attributes }
              issue.reload
            end.to change(issue, :summary).to("New Summary")
          end

          it "updates the requested issue status" do
            issue = Fabricate(:issue, project: project, user: admin)
            issue.update_attribute :closed, true
            Fabricate(:approved_resolution, issue: issue)

            expect do
              put :update, params: { id: issue.to_param,
                                     issue: new_attributes }
              issue.reload
            end.to change(issue, :status).to("resolved")
          end

          it "redirects to the issue" do
            issue = Fabricate(:issue, project: project, user: admin)
            url = issue_url(issue)

            put :update, params: { id: issue.to_param,
                                   issue: new_attributes }
            expect(response).to redirect_to(url)
          end
        end

        context "with invalid params" do
          it "returns a success response ('edit' template)" do
            issue = Fabricate(:issue, project: project, user: admin)
            put :update, params: { id: issue.to_param,
                                   issue: invalid_attributes }
            expect(response).to be_successful
          end
        end
      end

      context "for someone else's Issue" do
        context "with valid params" do
          it "updates the requested issue" do
            issue = Fabricate(:issue, project: project)

            expect do
              put :update, params: { id: issue.to_param,
                                     issue: new_attributes }
              issue.reload
            end.to change(issue, :summary).to("New Summary")
          end

          it "redirects to the issue" do
            issue = Fabricate(:issue, project: project)
            url = issue_url(issue)

            put :update, params: { id: issue.to_param,
                                   issue: new_attributes }
            expect(response).to redirect_to(url)
          end
        end

        context "with invalid params" do
          it "returns a success response ('edit' template)" do
            issue = Fabricate(:issue, project: project)
            put :update, params: { id: issue.to_param,
                                   issue: invalid_attributes }
            expect(response).to be_successful
          end
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        context "for their own Issue" do
          context "with valid params" do
            it "updates the requested issue" do
              issue = Fabricate(:issue, project: project, user: current_user)

              expect do
                put :update, params: { id: issue.to_param,
                                       issue: new_attributes }
                issue.reload
              end.to change(issue, :summary).to("New Summary")
            end

            it "redirects to the issue" do
              issue = Fabricate(:issue, project: project, user: current_user)
              url = issue_url(issue)

              put :update, params: { id: issue.to_param,
                                     issue: new_attributes }
              expect(response).to redirect_to(url)
            end
          end

          context "with invalid params" do
            it "returns a success response ('edit' template)" do
              issue = Fabricate(:issue, project: project, user: current_user)
              put :update, params: { id: issue.to_param,
                                     issue: invalid_attributes }
              expect(response).to be_successful
            end
          end
        end

        context "for someone else's Issue" do
          it "should be unauthorized" do
            issue = Fabricate(:issue, project: project)
            put :update, params: { id: issue.to_param,
                                   issue: new_attributes }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end
  end

  describe "DELETE #destroy" do
    context "for an admin" do
      before { sign_in(admin) }

      it "destroys the requested issue" do
        issue = Fabricate(:issue, project: project)
        expect do
          delete :destroy, params: { project_id: project.to_param,
                                     id: issue.to_param }
        end.to change(Issue, :count).by(-1)
      end

      it "redirects to the issues list" do
        issue = Fabricate(:issue, project: project)
        delete :destroy, params: { project_id: project.to_param,
                                   id: issue.to_param }
        expect(response).to redirect_to(project)
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        it "should be unauthorized" do
          issue = Fabricate(:issue, project: project, user: current_user)
          delete :destroy, params: { project_id: project.to_param,
                                     id: issue.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end
end
