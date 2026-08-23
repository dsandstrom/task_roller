require "rails_helper"

RSpec.describe IssuesController, type: :controller do
  include ActiveJob::TestHelper

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
        end
      end
    end
  end

  describe "GET #new" do
    context "for an admin" do
      before { sign_in(admin) }

      context "when IssueType and Project" do
        before { Fabricate(:issue_type) }

        context "and project_id param" do
          it "returns a success response" do
            get :new, params: { project_id: project.to_param }
            expect(response).to be_successful
          end
        end

        context "and no params" do
          before { Fabricate(:project) }

          it "returns a success response" do
            get :new
            expect(response).to be_successful
          end
        end
      end

      context "when no IssueTypes" do
        before { Fabricate(:project) }

        it "redirects to issue_types_url" do
          get :new
          expect(response).to redirect_to(issue_types_url)
        end
      end

      context "when internal Project" do
        before do
          Fabricate(:issue_type)
          Fabricate(:internal_project)
        end

        it "returns a success response" do
          get :new
          expect(response).to be_successful
        end
      end

      context "when no Projects" do
        before { Fabricate(:issue_type) }

        it "redirects to root_url" do
          get :new
          expect(response).to redirect_to(root_url)
        end
      end

      context "when no visible Projects" do
        before do
          Fabricate(:issue_type)
          Fabricate(:invisible_project)
        end

        it "redirects to root_url" do
          get :new
          expect(response).to redirect_to(root_url)
        end
      end
    end

    %w[reviewer worker].each do |employee_type|
      context "for a #{employee_type}" do
        before { sign_in(Fabricate("user_#{employee_type.downcase}")) }

        context "when an IssueType and Project" do
          before { Fabricate(:issue_type) }

          context "and project_id param" do
            it "returns a success response" do
              get :new, params: { project_id: project.to_param }
              expect(response).to be_successful
            end
          end

          context "and no params" do
            before { Fabricate(:project) }

            it "returns a success response" do
              get :new
              expect(response).to be_successful
            end
          end
        end

        context "when internal Project" do
          before do
            Fabricate(:issue_type)
            Fabricate(:internal_project)
          end

          it "returns a success response" do
            get :new
            expect(response).to be_successful
          end
        end

        context "when no IssueTypes" do
          before { Fabricate(:project) }

          it "redirects to root" do
            get :new
            expect(response).to redirect_to(root_url)
          end
        end

        context "when no Projects" do
          before { Fabricate(:issue_type) }

          it "redirects to root" do
            get :new
            expect(response).to redirect_to(root_url)
          end
        end

        context "when no visible Projects" do
          before do
            Fabricate(:issue_type)
            Fabricate(:invisible_project)
          end

          it "redirects to root" do
            get :new
            expect(response).to redirect_to(root_url)
          end
        end
      end
    end

    context "for a reporter" do
      let(:reporter) { Fabricate(:user_reporter) }

      before { sign_in(reporter) }

      context "when an IssueType and Project" do
        before { Fabricate(:issue_type) }

        context "and project_id param" do
          it "returns a success response" do
            get :new, params: { project_id: project.to_param }
            expect(response).to be_successful
          end
        end

        context "and no params" do
          before { Fabricate(:project) }

          it "returns a success response" do
            get :new
            expect(response).to be_successful
          end
        end
      end

      context "when internal Project" do
        before do
          Fabricate(:issue_type)
          Fabricate(:internal_project)
        end

        it "redirect_to root" do
          get :new
          expect(response).to redirect_to(root_url)
        end
      end

      context "when no IssueTypes" do
        before { Fabricate(:project) }

        it "redirects to root" do
          get :new
          expect(response).to redirect_to(root_url)
        end
      end

      context "when no Projects" do
        before { Fabricate(:issue_type) }

        it "redirects to root" do
          get :new
          expect(response).to redirect_to(root_url)
        end
      end

      context "when no visible Projects" do
        before do
          Fabricate(:issue_type)
          Fabricate(:invisible_project)
        end

        it "redirects to root" do
          get :new
          expect(response).to redirect_to(root_url)
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

      context "for Issue from internal project" do
        let(:project) { Fabricate(:internal_project) }

        it "returns a success response" do
          issue = Fabricate(:issue, project: project, user: admin)
          get :edit, params: { id: issue.to_param }
          expect(response).to be_successful
        end
      end

      context "for Issue from invisible project" do
        let(:project) { Fabricate(:invisible_project) }

        it "returns a success response" do
          issue = Fabricate(:issue, project: project, user: admin)
          get :edit, params: { id: issue.to_param }
          expect(response).to be_successful
        end
      end
    end

    %w[reviewer worker].each do |employee_type|
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

        context "for Issue form internal" do
          let(:project) { Fabricate(:internal_project) }

          it "returns a success response" do
            issue = Fabricate(:issue, project: project, user: current_user)
            get :edit, params: { id: issue.to_param }
            expect(response).to be_successful
          end
        end

        context "for Issue form invisible" do
          let(:project) { Fabricate(:invisible_project) }

          it "should be unauthorized" do
            issue = Fabricate(:issue, project: project, user: current_user)
            get :edit, params: { id: issue.to_param }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end

    context "for a reporter" do
      let(:current_user) { Fabricate(:user_reporter) }

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

      context "for Issue form internal" do
        let(:project) { Fabricate(:internal_project) }

        it "should be unauthorized" do
          issue = Fabricate(:issue, project: project, user: current_user)
          get :edit, params: { id: issue.to_param }
          expect_to_be_unauthorized(response)
        end
      end

      context "for Issue form invisible" do
        let(:project) { Fabricate(:invisible_project) }

        it "should be unauthorized" do
          issue = Fabricate(:issue, project: project, user: current_user)
          get :edit, params: { id: issue.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "POST #create" do
    %w[admin reviewer worker].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when visible/external project" do
          context "with valid params" do
            before { valid_attributes[:project_id] = project.to_param }

            it "creates a new Issue" do
              expect do
                post :create, params: { issue: valid_attributes }
              end.to change(current_user.issues, :count).by(1)
            end

            it "sets new Issue status as 'pending'" do
              post :create, params: { issue: valid_attributes }
              issue = Issue.last
              expect(issue).not_to be_nil
              expect(issue.status).to eq("pending")
            end

            it "enqueues a IssueSubscriptionsJob" do
              post :create, params: { issue: valid_attributes }

              expect(IssueSubscriptionsJob).to have_been_enqueued.exactly(:once)
            end

            it "redirects to the created issue" do
              post :create, params: { issue: valid_attributes }
              url = issue_path(Issue.last)
              expect(response).to redirect_to(url)
            end

            context "when someone subscribed to category" do
              let(:user) { Fabricate(:user_reviewer) }

              before do
                Fabricate(:category_issues_subscription, user: user,
                                                         category: category)
              end

              it "enqueues a IssueSubscriptionsJob" do
                post :create, params: { issue: valid_attributes }

                expect(IssueSubscriptionsJob)
                  .to have_been_enqueued.exactly(:once)
              end
            end

            context "when someone subscribed to project" do
              let(:user) { Fabricate(:user_reviewer) }

              before do
                Fabricate(:project_issues_subscription, user: user,
                                                        project: project)
              end

              it "enqueues a IssueSubscriptionsJob" do
                post :create, params: { issue: valid_attributes }

                expect(IssueSubscriptionsJob)
                  .to have_been_enqueued.exactly(:once)
              end
            end
          end

          context "with invalid params" do
            before { invalid_attributes[:project_id] = project.to_param }

            it "doesn't create a new Issue" do
              expect do
                post :create, params: { issue: invalid_attributes }
              end.not_to change(Issue, :count)
            end

            it "returns a success response ('new' template)" do
              post :create, params: { issue: invalid_attributes }
              expect(response).to be_successful
            end
          end
        end

        context "when visible/internal project" do
          let(:project) { Fabricate(:internal_project) }

          context "with valid params" do
            before { valid_attributes[:project_id] = project.to_param }

            it "creates a new Issue" do
              expect do
                post :create, params: { issue: valid_attributes }
              end.to change(current_user.issues, :count).by(1)
            end

            it "redirects to the created issue" do
              post :create, params: { issue: valid_attributes }
              url = issue_path(Issue.last)
              expect(response).to redirect_to(url)
            end
          end
        end

        context "when invisible project" do
          let(:project) { Fabricate(:invisible_project) }

          context "with valid params" do
            before { valid_attributes[:project_id] = project.to_param }

            it "doen't create a new Issue" do
              expect do
                post :create, params: { issue: valid_attributes }
              end.not_to change(Issue, :count)
            end

            it "redirects to unauthorized" do
              post :create, params: { issue: valid_attributes }
              expect_to_be_unauthorized(response)
            end
          end
        end
      end
    end

    context "for a reporter" do
      let(:current_user) { Fabricate(:user_reporter) }

      before { sign_in(current_user) }

      context "when visible/external project" do
        context "with valid params" do
          before { valid_attributes[:project_id] = project.to_param }

          it "creates a new Issue" do
            expect do
              post :create, params: { issue: valid_attributes }
            end.to change(current_user.issues, :count).by(1)
          end

          it "sets new Issue status as 'pending'" do
            post :create, params: { issue: valid_attributes }
            issue = Issue.last
            expect(issue).not_to be_nil
            expect(issue.status).to eq("pending")
          end

          it "enqueues a IssueSubscriptionsJob" do
            post :create, params: { issue: valid_attributes }

            expect(IssueSubscriptionsJob).to have_been_enqueued.exactly(:once)
          end

          it "redirects to the created issue" do
            post :create, params: { issue: valid_attributes }
            url = issue_path(Issue.last)
            expect(response).to redirect_to(url)
          end

          context "when someone subscribed to category" do
            let(:user) { Fabricate(:user_reviewer) }

            before do
              Fabricate(:category_issues_subscription, user: user,
                                                       category: category)
            end

            it "enqueues a IssueSubscriptionsJob" do
              post :create, params: { issue: valid_attributes }

              expect(IssueSubscriptionsJob).to have_been_enqueued.exactly(:once)
            end
          end

          context "when someone subscribed to project" do
            let(:user) { Fabricate(:user_reviewer) }

            before do
              Fabricate(:project_issues_subscription, user: user,
                                                      project: project)
            end

            it "enqueues a IssueSubscriptionsJob" do
              post :create, params: { issue: valid_attributes }

              expect(IssueSubscriptionsJob).to have_been_enqueued.exactly(:once)
            end
          end
        end

        context "with invalid params" do
          before { invalid_attributes[:project_id] = project.to_param }

          it "doesn't create a new Issue" do
            expect do
              post :create, params: { issue: invalid_attributes }
            end.not_to change(Issue, :count)
          end

          it "returns a success response ('new' template)" do
            post :create, params: { issue: invalid_attributes }
            expect(response).to be_successful
          end
        end
      end

      context "when visible/internal project" do
        let(:project) { Fabricate(:internal_project) }

        context "with valid params" do
          before { valid_attributes[:project_id] = project.to_param }

          it "doen't create a new Issue" do
            expect do
              post :create, params: { issue: valid_attributes }
            end.not_to change(Issue, :count)
          end

          it "redirects to unauthorized" do
            post :create, params: { issue: valid_attributes }
            expect_to_be_unauthorized(response)
          end
        end
      end

      context "when invisible project" do
        let(:project) { Fabricate(:invisible_project) }

        context "with valid params" do
          before { valid_attributes[:project_id] = project.to_param }

          it "doen't create a new Issue" do
            expect do
              post :create, params: { issue: valid_attributes }
            end.not_to change(Issue, :count)
          end

          it "redirects to unauthorized" do
            post :create, params: { issue: valid_attributes }
            expect_to_be_unauthorized(response)
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

        context "with new project_id in params" do
          let(:new_project) { Fabricate(:project) }

          before { new_attributes[:project_id] = new_project.id }

          it "doesn't update the project" do
            issue = Fabricate(:issue, project: project)

            expect do
              put :update, params: { id: issue.to_param,
                                     issue: new_attributes }
              issue.reload
            end.not_to change(issue, :project_id)
          end
        end
      end

      context "for Issue from internal project" do
        let(:project) { Fabricate(:internal_project) }

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
      end

      context "for Issue from invisible project" do
        let(:project) { Fabricate(:invisible_project) }

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
      end
    end

    %w[reviewer worker].each do |employee_type|
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

        context "for Issue from internal project" do
          let(:project) { Fabricate(:internal_project) }

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
        end

        context "for Issue from invisible project" do
          let(:project) { Fabricate(:invisible_project) }

          context "with valid params" do
            it "doesn't update the requested issue" do
              issue = Fabricate(:issue, project: project, user: current_user)

              expect do
                put :update, params: { id: issue.to_param,
                                       issue: new_attributes }
                issue.reload
              end.not_to change(issue, :summary)
            end

            it "redirects to unauthorized" do
              issue = Fabricate(:issue, project: project, user: current_user)

              put :update, params: { id: issue.to_param,
                                     issue: new_attributes }
              expect_to_be_unauthorized(response)
            end
          end
        end
      end
    end

    context "for a reporter" do
      let(:current_user) { Fabricate(:user_reporter) }

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

      context "for Issue from internal project" do
        let(:project) { Fabricate(:internal_project) }

        context "with valid params" do
          it "doesn't update the requested issue" do
            issue = Fabricate(:issue, project: project, user: current_user)

            expect do
              put :update, params: { id: issue.to_param,
                                     issue: new_attributes }
              issue.reload
            end.not_to change(issue, :summary)
          end

          it "redirects to unauthorized" do
            issue = Fabricate(:issue, project: project, user: current_user)

            put :update, params: { id: issue.to_param,
                                   issue: new_attributes }
            expect_to_be_unauthorized(response)
          end
        end
      end

      context "for Issue from invisible project" do
        let(:project) { Fabricate(:invisible_project) }

        context "with valid params" do
          it "doesn't update the requested issue" do
            issue = Fabricate(:issue, project: project, user: current_user)

            expect do
              put :update, params: { id: issue.to_param,
                                     issue: new_attributes }
              issue.reload
            end.not_to change(issue, :summary)
          end

          it "redirects to unauthorized" do
            issue = Fabricate(:issue, project: project, user: current_user)

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
