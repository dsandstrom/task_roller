# frozen_string_literal: true

require "rails_helper"

RSpec.describe TasksController, type: :controller do
  let(:task_type) { Fabricate(:task_type) }
  let(:user) { Fabricate(:user_reporter) }
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:issue) { Fabricate(:issue, project: project) }
  let(:admin) { Fabricate(:user_admin) }
  let(:worker) { Fabricate(:user_worker) }

  let(:valid_attributes) do
    { task_type_id: task_type.id, summary: "Summary",
      description: "Description" }
  end

  let(:invalid_attributes) { { summary: "" } }

  describe "GET #index" do
    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        before { login(current_user) }

        context "when category is invisible and internal" do
          let(:category) do
            Fabricate(:category, visible: false, internal: true)
          end
          let(:project) { Fabricate(:project, category: category) }

          it "returns a success response" do
            Fabricate(:task, project: project)
            Fabricate(:task, project: project, user: current_user)
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
            Fabricate(:task, project: project)
            Fabricate(:task, project: project, user: current_user)
            get :index, params: { project_id: project.to_param }
            expect(response).to be_successful
          end
        end

        context "when user" do
          context "is an employee" do
            it "returns a success response" do
              Fabricate(:task, user: user)
              get :index, params: { user_id: user.to_param }
              expect(response).to be_successful
            end
          end

          # context "is not an employee" do
          #   before { user.update employee_type: nil }
          #
          #   it "should be unauthorized" do
          #     Fabricate(:task, user: user)
          #     get :index, params: { user_id: user.to_param }
          #     expect_to_be_unauthorized(response)
          #   end
          # end
        end
      end
    end

    %w[worker].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { login(current_user) }

        context "when category" do
          context "is visible" do
            context "and external" do
              let(:category) do
                Fabricate(:category, visible: true, internal: false)
              end
              let(:project) { Fabricate(:project, category: category) }

              it "returns a success response" do
                Fabricate(:task, project: project)
                Fabricate(:task, project: project, user: current_user)
                get :index, params: { category_id: category.to_param }
                expect(response).to be_successful
              end

              context "and internal" do
                let(:category) do
                  Fabricate(:category, visible: true, internal: true)
                end
                let(:project) { Fabricate(:project, category: category) }

                it "returns a success response" do
                  Fabricate(:task, project: project)
                  Fabricate(:task, project: project, user: current_user)
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
                Fabricate(:task, project: project)
                Fabricate(:task, project: project, user: current_user)
                get :index, params: { category_id: category.to_param }
                expect_to_be_unauthorized(response)
              end

              context "and internal" do
                let(:category) do
                  Fabricate(:category, visible: false, internal: true)
                end
                let(:project) { Fabricate(:project, category: category) }

                it "should be unauthorized" do
                  Fabricate(:task, project: project)
                  Fabricate(:task, project: project, user: current_user)
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
                    Fabricate(:task, project: project)
                    Fabricate(:task, project: project, user: current_user)
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
                    Fabricate(:task, project: project)
                    Fabricate(:task, project: project, user: current_user)
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
                    Fabricate(:task, project: project)
                    Fabricate(:task, project: project, user: current_user)
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
                    Fabricate(:task, project: project)
                    Fabricate(:task, project: project, user: current_user)
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
                    Fabricate(:task, project: project)
                    Fabricate(:task, project: project, user: current_user)
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
                    Fabricate(:task, project: project)
                    Fabricate(:task, project: project, user: current_user)
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
                    Fabricate(:task, project: project)
                    Fabricate(:task, project: project, user: current_user)
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
                    Fabricate(:task, project: project)
                    Fabricate(:task, project: project, user: current_user)
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
              Fabricate(:task, project: project)
              Fabricate(:task, project: project, user: current_user)
              get :index, params: { project_id: project.to_param }
              expect_to_be_unauthorized(response)
            end
          end
        end

        context "when user" do
          context "is an employee" do
            it "returns a success response" do
              Fabricate(:task, user: user)
              get :index, params: { user_id: user.to_param }
              expect(response).to be_successful
            end
          end

          # context "is not an employee" do
          #   before { user.update employee_type: nil }
          #
          #   it "should be unauthorized" do
          #     Fabricate(:task, user: user)
          #     get :index, params: { user_id: user.to_param }
          #     expect_to_be_unauthorized(response)
          #   end
          # end
        end
      end
    end

    %w[reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        before { login(current_user) }

        context "when category" do
          context "is visible" do
            context "and external" do
              let(:category) do
                Fabricate(:category, visible: true, internal: false)
              end
              let(:project) { Fabricate(:project, category: category) }

              it "returns a success response" do
                Fabricate(:task, project: project)
                Fabricate(:task, project: project, user: current_user)
                get :index, params: { category_id: category.to_param }
                expect(response).to be_successful
              end

              context "and internal" do
                let(:category) do
                  Fabricate(:category, visible: true, internal: true)
                end
                let(:project) { Fabricate(:project, category: category) }

                it "should be unauthorized" do
                  Fabricate(:task, project: project)
                  Fabricate(:task, project: project, user: current_user)
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
                Fabricate(:task, project: project)
                Fabricate(:task, project: project, user: current_user)
                get :index, params: { category_id: category.to_param }
                expect_to_be_unauthorized(response)
              end

              context "and internal" do
                let(:category) do
                  Fabricate(:category, visible: false, internal: true)
                end
                let(:project) { Fabricate(:project, category: category) }

                it "should be unauthorized" do
                  Fabricate(:task, project: project)
                  Fabricate(:task, project: project, user: current_user)
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
                    Fabricate(:task, project: project)
                    Fabricate(:task, project: project, user: current_user)
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
                    Fabricate(:task, project: project)
                    Fabricate(:task, project: project, user: current_user)
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
                    Fabricate(:task, project: project)
                    Fabricate(:task, project: project, user: current_user)
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
                    Fabricate(:task, project: project)
                    Fabricate(:task, project: project, user: current_user)
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
                    Fabricate(:task, project: project)
                    Fabricate(:task, project: project, user: current_user)
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
                    Fabricate(:task, project: project)
                    Fabricate(:task, project: project, user: current_user)
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
                    Fabricate(:task, project: project)
                    Fabricate(:task, project: project, user: current_user)
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
                    Fabricate(:task, project: project)
                    Fabricate(:task, project: project, user: current_user)
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
              Fabricate(:task, project: project)
              Fabricate(:task, project: project, user: current_user)
              get :index, params: { project_id: project.to_param }
              expect_to_be_unauthorized(response)
            end
          end
        end

        context "when user" do
          context "is an employee" do
            it "returns a success response" do
              Fabricate(:task, user: user)
              get :index, params: { user_id: user.to_param }
              expect(response).to be_successful
            end
          end

          # context "is not an employee" do
          #   before { user.update employee_type: nil }
          #
          #   it "should be unauthorized" do
          #     Fabricate(:task, user: user)
          #     get :index, params: { user_id: user.to_param }
          #     expect_to_be_unauthorized(response)
          #   end
          # end
        end
      end
    end
  end

  describe "GET #show" do
    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        context "when category/project are invisible and internal" do
          let(:category) do
            Fabricate(:category, visible: false, internal: true)
          end
          let(:project) do
            Fabricate(:project, category: category, visible: false,
                                internal: true)
          end

          before { login(current_user) }

          context "when someone else's task" do
            it "returns a success response" do
              task = Fabricate(:task, project: project)
              get :show, params: { category_id: category.to_param,
                                   project_id: project.to_param,
                                   id: task.to_param }
              expect(response).to be_successful
            end
          end

          context "when their task" do
            it "returns a success response" do
              task = Fabricate(:task, project: project, user: current_user)
              get :show, params: { category_id: category.to_param,
                                   project_id: project.to_param,
                                   id: task.to_param }
              expect(response).to be_successful
            end
          end
        end
      end
    end

    %w[worker].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

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

                before { login(current_user) }

                it "returns a success response" do
                  task = Fabricate(:task, project: project)
                  get :show, params: { category_id: category.to_param,
                                       project_id: project.to_param,
                                       id: task.to_param }
                  expect(response).to be_successful
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, visible: true,
                                      internal: true)
                end

                before { login(current_user) }

                it "returns a success response" do
                  task = Fabricate(:task, project: project)
                  get :show, params: { category_id: category.to_param,
                                       project_id: project.to_param,
                                       id: task.to_param }
                  expect(response).to be_successful
                end
              end
            end

            context "while project is invisible" do
              context "and external" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: false)
                end

                before { login(current_user) }

                it "should be unauthorized" do
                  task = Fabricate(:task, project: project)
                  get :show, params: { category_id: category.to_param,
                                       project_id: project.to_param,
                                       id: task.to_param }
                  expect_to_be_unauthorized(response)
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

                before { login(current_user) }

                it "returns a success response" do
                  task = Fabricate(:task, project: project)
                  get :show, params: { category_id: category.to_param,
                                       project_id: project.to_param,
                                       id: task.to_param }
                  expect(response).to be_successful
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, visible: true,
                                      internal: true)
                end

                before { login(current_user) }

                it "returns a success response" do
                  task = Fabricate(:task, project: project)
                  get :show, params: { category_id: category.to_param,
                                       project_id: project.to_param,
                                       id: task.to_param }
                  expect(response).to be_successful
                end
              end
            end

            context "while project is invisible" do
              context "and external" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: false)
                end

                before { login(current_user) }

                it "should be unauthorized" do
                  task = Fabricate(:task, project: project)
                  get :show, params: { category_id: category.to_param,
                                       project_id: project.to_param,
                                       id: task.to_param }
                  expect_to_be_unauthorized(response)
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

                before { login(current_user) }

                it "should be unauthorized" do
                  task = Fabricate(:task, project: project)
                  get :show, params: { category_id: category.to_param,
                                       project_id: project.to_param,
                                       id: task.to_param }
                  expect_to_be_unauthorized(response)
                end
              end
            end
          end
        end
      end
    end

    %w[reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

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

                before { login(current_user) }

                it "returns a success response" do
                  task = Fabricate(:task, project: project)
                  get :show, params: { category_id: category.to_param,
                                       project_id: project.to_param,
                                       id: task.to_param }
                  expect(response).to be_successful
                end
              end

              context "and internal" do
                let(:project) do
                  Fabricate(:project, category: category, visible: true,
                                      internal: true)
                end

                before { login(current_user) }

                it "should be unauthorized" do
                  task = Fabricate(:task, project: project)
                  get :show, params: { category_id: category.to_param,
                                       project_id: project.to_param,
                                       id: task.to_param }
                  expect_to_be_unauthorized(response)
                end
              end
            end

            context "while project is invisible" do
              context "and external" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: false)
                end

                before { login(current_user) }

                it "should be unauthorized" do
                  task = Fabricate(:task, project: project)
                  get :show, params: { category_id: category.to_param,
                                       project_id: project.to_param,
                                       id: task.to_param }
                  expect_to_be_unauthorized(response)
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

                before { login(current_user) }

                it "should be unauthorized" do
                  task = Fabricate(:task, project: project)
                  get :show, params: { category_id: category.to_param,
                                       project_id: project.to_param,
                                       id: task.to_param }
                  expect_to_be_unauthorized(response)
                end
              end
            end

            context "while project is invisible" do
              context "and external" do
                let(:project) do
                  Fabricate(:project, category: category, visible: false,
                                      internal: false)
                end

                before { login(current_user) }

                it "should be unauthorized" do
                  task = Fabricate(:task, project: project)
                  get :show, params: { category_id: category.to_param,
                                       project_id: project.to_param,
                                       id: task.to_param }
                  expect_to_be_unauthorized(response)
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

                before { login(current_user) }

                it "should be unauthorized" do
                  task = Fabricate(:task, project: project)
                  get :show, params: { category_id: category.to_param,
                                       project_id: project.to_param,
                                       id: task.to_param }
                  expect_to_be_unauthorized(response)
                end
              end
            end
          end
        end
      end
    end
  end

  describe "GET #new" do
    before { Fabricate(:task_type) }

    %w[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        context "when project" do
          it "returns a success response" do
            get :new, params: { project_id: project.id }

            expect(response).to be_successful
          end
        end

        context "when project and issue" do
          it "returns a success response" do
            get :new, params: { project_id: project.to_param,
                                issue_id: issue.to_param }

            expect(response).to be_successful
          end
        end

        context "when no TaskTypes" do
          before do
            TaskType.destroy_all
            Fabricate(:user_reporter)
          end

          it "redirects to issue_types_url" do
            get :new, params: { project_id: project.to_param }
            expect(response).to redirect_to(issue_types_url)
          end
        end
      end
    end

    %w[reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        context "when project" do
          it "returns a success response" do
            get :new, params: { project_id: project.to_param }

            expect(response).to be_successful
          end
        end

        context "when project and issue" do
          it "returns a success response" do
            get :new, params: { project_id: project.to_param,
                                issue_id: issue.to_param }

            expect(response).to be_successful
          end
        end

        context "when no TaskTypes" do
          before { TaskType.destroy_all }

          it "redirects to project" do
            get :new, params: { project_id: project.to_param }
            expect(response).to redirect_to(root_url)
          end
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        it "should be unauthorized" do
          get :new, params: { category_id: category.to_param,
                              project_id: project.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "GET #edit" do
    %w[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        context "when their issue" do
          it "returns a success response" do
            task = Fabricate(:task, project: project, issue: issue,
                                    user: current_user)
            get :edit, params: { category_id: category.to_param,
                                 project_id: project.to_param,
                                 id: task.to_param }
            expect(response).to be_successful
          end
        end

        context "when someone else's issue" do
          it "returns a success response" do
            task = Fabricate(:task, project: project, issue: issue)
            get :edit, params: { category_id: category.to_param,
                                 project_id: project.to_param,
                                 id: task.to_param }
            expect(response).to be_successful
          end
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        context "when their issue" do
          it "returns a success response" do
            task = Fabricate(:task, project: project, issue: issue,
                                    user: current_user)
            get :edit, params: { category_id: category.to_param,
                                 project_id: project.to_param,
                                 id: task.to_param }
            expect(response).to be_successful
          end
        end

        context "when someone else's issue" do
          it "returns a success response" do
            task = Fabricate(:task, project: project, issue: issue)
            get :edit, params: { category_id: category.to_param,
                                 project_id: project.to_param,
                                 id: task.to_param }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end
  end

  describe "POST #create" do
    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        context "when project" do
          context "with valid params" do
            it "creates a new Project Task" do
              expect do
                post :create, params: { project_id: project.to_param,
                                        task: valid_attributes }
              end.to change(project.tasks, :count).by(1)
            end

            it "creates a new current_user Task" do
              expect do
                post :create, params: { project_id: project.to_param,
                                        task: valid_attributes }
              end.to change(current_user.tasks, :count).by(1)
            end

            it "creates a new current_user TaskSubscription" do
              expect do
                post :create, params: { project_id: project.to_param,
                                        task: valid_attributes }
              end.to change(current_user.task_subscriptions, :count).by(1)
            end

            it "redirects to the created task" do
              post :create, params: { project_id: project.to_param,
                                      task: valid_attributes }
              url = task_path(Task.last)
              expect(response).to redirect_to(url)
            end

            context "when a worker assigned" do
              before do
                Fabricate(:user_worker)
                valid_attributes.merge! assignee_ids: [worker.id]
              end

              it "creates 2 TaskSubscriptions" do
                expect do
                  post :create, params: { project_id: project.to_param,
                                          task: valid_attributes }
                end.to change(TaskSubscription, :count).by(2)
              end

              it "creates a new worker TaskSubscription" do
                expect do
                  post :create, params: { project_id: project.to_param,
                                          task: valid_attributes }
                end.to change(worker.task_subscriptions, :count).by(1)
              end
            end
          end

          context "with invalid params" do
            it "doesn't create a Task" do
              expect do
                post :create, params: { project_id: project.to_param,
                                        task: invalid_attributes }
              end.not_to change(Task, :count)
            end

            it "returns a success response ('new' template)" do
              post :create, params: { project_id: project.to_param,
                                      task: invalid_attributes }
              expect(response).to be_successful
            end
          end

          context "when assigning" do
            let(:user) { Fabricate(:user_worker) }

            before { valid_attributes.merge!(assignee_ids: [user.id]) }

            it "creates an assignment" do
              expect do
                post :create, params: { project_id: project.to_param,
                                        task: valid_attributes }
              end.to change(user.assignments, :count).by(1)
            end
          end
        end

        context "when project and issue" do
          before do
            valid_attributes.merge! issue_id: issue.to_param
            invalid_attributes.merge! issue_id: issue.to_param
          end

          context "with valid params" do
            it "creates a new Task" do
              expect do
                post :create, params: { project_id: project.to_param,
                                        task: valid_attributes }
              end.to change(issue.tasks, :count).by(1)
            end

            it "redirects to the created task" do
              post :create, params: { project_id: project.to_param,
                                      task: valid_attributes }
              url = task_path(Task.last)
              expect(response).to redirect_to(url)
            end
          end

          context "with invalid params" do
            it "doesn't create a Task" do
              expect do
                post :create, params: { project_id: project.to_param,
                                        task: invalid_attributes }
              end.not_to change(Task, :count)
            end

            it "returns a success response ('new' template)" do
              post :create, params: { project_id: project.to_param,
                                      task: invalid_attributes }
              expect(response).to be_successful
            end
          end
        end

        context "when someone subscribed to category" do
          let(:user) { Fabricate(:user_reviewer) }

          before do
            Fabricate(:category_tasks_subscription, user: user,
                                                    category: category)
          end

          it "creates a new IssueSubscription" do
            expect do
              post :create, params: { project_id: project.to_param,
                                      task: valid_attributes }
            end.to change(user.task_subscriptions, :count).by(1)
          end
        end

        context "when someone subscribed to project" do
          let(:user) { Fabricate(:user_reviewer) }

          before do
            Fabricate(:project_tasks_subscription, user: user,
                                                   project: project)
          end

          it "creates a new IssueSubscription" do
            expect do
              post :create, params: { project_id: project.to_param,
                                      task: valid_attributes }
            end.to change(user.task_subscriptions, :count).by(1)
          end
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        it "doesn't create a Task" do
          expect do
            post :create, params: { project_id: project.to_param,
                                    task: valid_attributes }
          end.not_to change(Task, :count)
        end

        it "should be unauthorized" do
          post :create, params: { project_id: project.to_param,
                                  task: valid_attributes }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "PUT #update" do
    let(:new_attributes) { { summary: "New Summary" } }

    %w[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        context "when their task" do
          context "with valid params" do
            it "updates the requested task" do
              task = Fabricate(:task, project: project, user: current_user)
              expect do
                put :update, params: { id: task.to_param,
                                       task: new_attributes }
                task.reload
              end.to change(task, :summary).to("New Summary")
            end

            it "redirects to the task" do
              task = Fabricate(:task, project: project, user: current_user)
              put :update, params: { id: task.to_param,
                                     task: new_attributes }
              url = task_url(task)
              expect(response).to redirect_to(url)
            end

            context "when a new worker assigned" do
              let(:reassigned) { Fabricate(:user_worker) }
              let(:stay_assigned) { Fabricate(:user_worker) }
              let(:assignee_ids) { [reassigned.id, stay_assigned.id] }
              let(:new_assignee_ids) { [worker.id, stay_assigned.id] }

              let(:task) do
                Fabricate(:task, project: project, user: current_user,
                                 assignee_ids: assignee_ids)
              end

              before do
                Fabricate(:user_worker)
                Fabricate(:task_subscription, task: task, user: reassigned)
                Fabricate(:task_subscription, task: task, user: stay_assigned)
                new_attributes.merge! assignee_ids: new_assignee_ids
              end

              it "creates 1 TaskSubscriptions" do
                expect do
                  put :update, params: { id: task.to_param,
                                         task: new_attributes }
                end.to change(TaskSubscription, :count).by(1)
              end

              it "creates a new worker TaskSubscription" do
                expect do
                  put :update, params: { id: task.to_param,
                                         task: new_attributes }
                end.to change(worker.task_subscriptions, :count).by(1)
              end

              it "doesn't change reassigned worker TaskSubscription" do
                task
                expect do
                  put :update, params: { id: task.to_param,
                                         task: new_attributes }
                end.not_to change(reassigned.task_subscriptions, :count)
              end

              it "doesn't change stay_assigned worker TaskSubscription" do
                task
                expect do
                  put :update, params: { id: task.to_param,
                                         task: new_attributes }
                end.not_to change(stay_assigned.task_subscriptions, :count)
              end
            end
          end

          context "with invalid params" do
            it "returns a success response ('edit' template)" do
              task = Fabricate(:task, project: project, user: current_user)
              put :update, params: { id: task.to_param,
                                     task: invalid_attributes }
              expect(response).to be_successful
            end
          end
        end

        context "when someone else's task" do
          context "with valid params" do
            it "updates the requested task" do
              task = Fabricate(:task, project: project, user: current_user)
              expect do
                put :update, params: { id: task.to_param,
                                       task: new_attributes }
                task.reload
              end.to change(task, :summary).to("New Summary")
            end
          end
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        context "when their task" do
          context "with valid params" do
            it "updates the requested task" do
              task = Fabricate(:task, project: project, user: current_user)
              expect do
                put :update, params: { id: task.to_param,
                                       task: new_attributes }
                task.reload
              end.to change(task, :summary).to("New Summary")
            end

            it "redirects to the task" do
              task = Fabricate(:task, project: project, user: current_user)
              put :update, params: { id: task.to_param,
                                     task: new_attributes }
              url = task_url(task)
              expect(response).to redirect_to(url)
            end
          end

          context "with invalid params" do
            it "returns a success response ('edit' template)" do
              task = Fabricate(:task, project: project, user: current_user)
              put :update, params: { id: task.to_param,
                                     task: invalid_attributes }
              expect(response).to be_successful
            end
          end
        end

        context "when someone else's task" do
          it "doesn't update the requested task" do
            task = Fabricate(:task, project: project)
            expect do
              put :update, params: { id: task.to_param,
                                     task: new_attributes }
              task.reload
            end.not_to change(task, :summary)
          end

          it "should be unauthorized" do
            task = Fabricate(:task, project: project)
            put :update, params: { id: task.to_param,
                                   task: new_attributes }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end
  end

  describe "DELETE #destroy" do
    %w[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        it "destroys the requested task" do
          task = Fabricate(:task, project: project)
          expect do
            delete :destroy, params: { project_id: project.to_param,
                                       id: task.to_param }
          end.to change(Task, :count).by(-1)
        end

        it "redirects to the tasks list" do
          task = Fabricate(:task, project: project)
          delete :destroy, params: { project_id: project.to_param,
                                     id: task.to_param }
          expect(response).to redirect_to(project)
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        it "doesn't destroy the requested task" do
          task = Fabricate(:task, project: project, user: current_user)
          expect do
            delete :destroy, params: { project_id: project.to_param,
                                       id: task.to_param }
          end.not_to change(Task, :count)
        end

        it "should be unauthorized" do
          task = Fabricate(:task, project: project, user: current_user)
          delete :destroy, params: { project_id: project.to_param,
                                     id: task.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end
end
