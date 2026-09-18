require "rails_helper"

RSpec.describe MoveTasksController, type: :controller do
  let(:old_project) { Fabricate(:project) }
  let(:project) { Fabricate(:project) }
  let(:source_task) { Fabricate(:task, project: project) }

  let(:valid_attributes) { { project_id: project.to_param } }
  let(:invalid_attributes) { { project_id: "" } }
  let(:valid_branch_attributes) { { source_task_id: source_task.to_param } }

  let(:invalid_branch_attributes) do
    { source_task_id: "", source_issue_id: "" }
  end

  before do
    Fabricate(:issue_type)
    Fabricate(:task_type)
  end

  describe "GET #new" do
    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        context "when a visible project" do
          before do
            Fabricate(:project)
          end

          it "returns a success response" do
            get :new
            expect(response).to be_successful
          end
        end

        context "when no visible projects" do
          before do
            Fabricate(:invisible_project)
          end

          it "redirects to categories" do
            get :new
            expect(response).to redirect_to(:root)
          end
        end

        context "when no projects" do
          before do
            Project.destroy_all
          end

          it "redirects to categories" do
            get :new
            expect(response).to redirect_to(:root)
          end
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        context "when a visible project" do
          before do
            Fabricate(:project)
          end

          it "should be unauthorized" do
            get :new
            expect_to_be_unauthorized(response)
          end
        end

        context "when no visible projects" do
          before do
            Fabricate(:invisible_project)
          end

          it "should be unauthorized" do
            get :new
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

        before { sign_in(current_user) }

        context "when html request" do
          context "with valid params" do
            context "for visible project" do
              it "redirects to new_project_task_path" do
                post :create, params: { task: valid_attributes }
                expect(response).to redirect_to(new_project_task_path(project))
              end
            end

            context "for internal project" do
              let(:project) { Fabricate(:internal_project) }

              it "redirects to new_project_task_path" do
                post :create, params: { task: valid_attributes }
                expect(response).to redirect_to(new_project_task_path(project))
              end
            end

            context "for invisible project and no visible projects" do
              let(:project) { Fabricate(:invisible_project) }

              it "redirects to root" do
                post :create, params: { task: valid_attributes }
                expect(response).to redirect_to(:root)
              end
            end

            context "for invisible project but a visible project" do
              let(:project) { Fabricate(:invisible_project) }

              before do
                Fabricate(:project)
              end

              it "should be unauthorized" do
                post :create, params: { task: valid_attributes }
                expect_to_be_unauthorized(response)
              end
            end
          end

          context "with invalid params" do
            context "when a visible project" do
              before do
                Fabricate(:project)
              end

              it "renders new" do
                post :create, params: { task: invalid_attributes }
                expect(response).to be_successful
              end
            end

            context "when no visible projects" do
              before do
                Fabricate(:invisible_project)
              end

              it "renders new" do
                post :create, params: { task: invalid_attributes }
                expect(response).to redirect_to(:root)
              end
            end

            context "when no projects" do
              before do
                Project.destroy_all
              end

              it "renders new" do
                post :create, params: { task: invalid_attributes }
                expect(response).to redirect_to(:root)
              end
            end
          end
        end

        context "when turbo_stream request" do
          context "with valid params" do
            context "for a visible project" do
              context "and no task_branch params" do
                it "renders create" do
                  post :create, params: { task: valid_attributes },
                                as: :turbo_stream
                  expect(response).to be_successful
                end
              end

              context "and valid task_branch params" do
                it "renders create" do
                  post :create,
                       params: { task: valid_attributes,
                                 task_branch: valid_branch_attributes },
                       as: :turbo_stream
                  expect(response).to be_successful
                end
              end

              context "and invalid task_branch params" do
                it "renders create" do
                  post :create,
                       params: { task: valid_attributes,
                                 task_branch: invalid_branch_attributes },
                       as: :turbo_stream
                  expect(response).to be_successful
                end
              end
            end

            context "for an invisible project and no visible" do
              let(:project) { Fabricate(:invisible_project) }

              context "and no task_branch params" do
                it "renders create" do
                  post :create, params: { task: valid_attributes },
                                as: :turbo_stream
                  expect(response).to redirect_to(:root)
                end
              end

              context "and valid task_branch params" do
                it "renders create" do
                  post :create,
                       params: { task: valid_attributes,
                                 task_branch: valid_branch_attributes },
                       as: :turbo_stream
                  expect(response).to redirect_to(:root)
                end
              end

              context "and invalid task_branch params" do
                it "renders create" do
                  post :create,
                       params: { task: valid_attributes,
                                 task_branch: invalid_branch_attributes },
                       as: :turbo_stream
                  expect(response).to redirect_to(:root)
                end
              end
            end

            context "for an invisible project but visible projects" do
              let(:project) { Fabricate(:invisible_project) }

              before do
                Fabricate(:project)
              end

              context "and no task_branch params" do
                it "renders create" do
                  post :create, params: { task: valid_attributes },
                                as: :turbo_stream
                  expect_to_be_forbidden(response)
                end
              end

              context "and valid task_branch params" do
                it "renders create" do
                  post :create,
                       params: { task: valid_attributes,
                                 task_branch: valid_branch_attributes },
                       as: :turbo_stream
                  expect_to_be_forbidden(response)
                end
              end

              context "and invalid task_branch params" do
                it "renders create" do
                  post :create,
                       params: { task: valid_attributes,
                                 task_branch: invalid_branch_attributes },
                       as: :turbo_stream
                  expect_to_be_forbidden(response)
                end
              end
            end
          end

          context "with invalid params" do
            context "and visible project" do
              before do
                Fabricate(:project)
              end

              context "and no task_branch params" do
                it "renders create" do
                  post :create, params: { task: invalid_attributes },
                                as: :turbo_stream
                  expect(response).to be_successful
                end
              end

              context "and valid task_branch params" do
                it "renders new" do
                  post :create,
                       params: { task: invalid_attributes,
                                 task_branch: valid_branch_attributes },
                       as: :turbo_stream
                  expect(response).to be_successful
                end
              end

              context "and invalid task_branch params" do
                it "renders new" do
                  post :create,
                       params: { task: invalid_attributes,
                                 task_branch: invalid_branch_attributes },
                       as: :turbo_stream
                  expect(response).to be_successful
                end
              end
            end

            context "and no visible projects" do
              let(:project) { Fabricate(:invisible_project) }

              before do
                Fabricate(:invisible_project)
              end

              context "and no task_branch params" do
                it "renders create" do
                  post :create, params: { task: invalid_attributes },
                                as: :turbo_stream
                  expect(response).to redirect_to(:root)
                end
              end

              context "and valid task_branch params" do
                it "renders new" do
                  post :create,
                       params: { task: invalid_attributes,
                                 task_branch: valid_branch_attributes },
                       as: :turbo_stream
                  expect(response).to redirect_to(:root)
                end
              end

              context "and invalid task_branch params" do
                it "renders new" do
                  post :create,
                       params: { task: invalid_attributes,
                                 task_branch: invalid_branch_attributes },
                       as: :turbo_stream
                  expect(response).to redirect_to(:root)
                end
              end
            end
          end

          context "with valid params for full task" do
            context "for visible project" do
              before do
                valid_attributes.merge!(
                  summary: "Summary",
                  description: "Description",
                  task_type_id: Fabricate(:task_type).to_param,
                  issue_id: Fabricate(:issue, project: project).to_param,
                  assignee_ids: [Fabricate(:user_worker).to_param]
                )
              end

              context "and no task_branch params" do
                it "renders create" do
                  post :create, params: { task: valid_attributes },
                                as: :turbo_stream
                  expect(response).to be_successful
                end
              end

              context "and valid task_branch params" do
                it "renders create" do
                  post :create,
                       params: { task: valid_attributes,
                                 task_branch: valid_branch_attributes },
                       as: :turbo_stream
                  expect(response).to be_successful
                end
              end

              context "and invalid task_branch params" do
                it "renders create" do
                  post :create,
                       params: { task: valid_attributes,
                                 task_branch: invalid_branch_attributes },
                       as: :turbo_stream
                  expect(response).to be_successful
                end
              end
            end

            context "for invisible project and no visible" do
              let(:project) { Fabricate(:invisible_project) }

              before do
                valid_attributes.merge!(
                  summary: "Summary",
                  description: "Description",
                  task_type_id: Fabricate(:task_type).to_param,
                  issue_id: Fabricate(:issue, project: project).to_param,
                  assignee_ids: [Fabricate(:user_worker).to_param]
                )
              end

              context "and no task_branch params" do
                it "redirects to root" do
                  post :create, params: { task: valid_attributes },
                                as: :turbo_stream
                  expect(response).to redirect_to(:root)
                end
              end

              context "and valid task_branch params" do
                it "redirects to root" do
                  post :create,
                       params: { task: valid_attributes,
                                 task_branch: valid_branch_attributes },
                       as: :turbo_stream
                  expect(response).to redirect_to(:root)
                end
              end

              context "and invalid task_branch params" do
                it "redirects to root" do
                  post :create,
                       params: { task: valid_attributes,
                                 task_branch: invalid_branch_attributes },
                       as: :turbo_stream
                  expect(response).to redirect_to(:root)
                end
              end
            end

            context "for invisible project but a visible project" do
              let(:project) { Fabricate(:invisible_project) }

              before do
                Fabricate(:project)
              end

              before do
                valid_attributes.merge!(
                  summary: "Summary",
                  description: "Description",
                  task_type_id: Fabricate(:task_type).to_param,
                  issue_id: Fabricate(:issue, project: project).to_param,
                  assignee_ids: [Fabricate(:user_worker).to_param]
                )
              end

              context "and no task_branch params" do
                it "renders create" do
                  post :create, params: { task: valid_attributes },
                                as: :turbo_stream
                  expect_to_be_forbidden(response)
                end
              end

              context "and valid task_branch params" do
                it "renders create" do
                  post :create,
                       params: { task: valid_attributes,
                                 task_branch: valid_branch_attributes },
                       as: :turbo_stream
                  expect_to_be_forbidden(response)
                end
              end

              context "and invalid task_branch params" do
                it "renders create" do
                  post :create,
                       params: { task: valid_attributes,
                                 task_branch: invalid_branch_attributes },
                       as: :turbo_stream
                  expect_to_be_forbidden(response)
                end
              end
            end
          end

          context "with javascript assignee_ids" do
            let(:first_worker) { Fabricate(:user_worker) }
            let(:second_worker) { Fabricate(:user_worker) }
            let(:assignee_ids) { "#{first_worker.id}, #{second_worker.id}" }

            before { valid_attributes.merge!(assignee_ids: [assignee_ids]) }

            it "renders create" do
              post :create, params: { task: valid_attributes,
                                      task_branch: valid_branch_attributes },
                            as: :turbo_stream
              expect(response).to be_successful
            end
          end

          context "with rails assignee_ids" do
            let(:first_worker) { Fabricate(:user_worker) }
            let(:second_worker) { Fabricate(:user_worker) }
            let(:assignee_ids) do
              [first_worker.id.to_s, second_worker.id.to_s]
            end

            before { valid_attributes.merge!(assignee_ids: [assignee_ids]) }

            it "renders create" do
              post :create, params: { task: valid_attributes,
                                      task_branch: valid_branch_attributes },
                            as: :turbo_stream
              expect(response).to be_successful
            end
          end
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        context "for visible project" do
          context "when html request" do
            it "should be unauthorized" do
              post :create, params: { task: valid_attributes }
              expect_to_be_unauthorized(response)
            end
          end

          context "when turbo_stream request" do
            context "when no task_branch params" do
              it "should be unauthorized" do
                post :create, params: { task: valid_attributes },
                              as: :turbo_stream
                expect_to_be_forbidden(response)
              end
            end

            context "when task_branch params" do
              it "should be unauthorized" do
                post :create, params: { task: valid_attributes,
                                        task_branch: valid_branch_attributes },
                              as: :turbo_stream
                expect_to_be_forbidden(response)
              end
            end
          end
        end

        context "for invisible project and no visible" do
          let(:project) { Fabricate(:invisible_project) }

          context "when html request" do
            it "should be unauthorized" do
              post :create, params: { task: valid_attributes }
              expect_to_be_unauthorized(response)
            end
          end

          context "when turbo_stream request" do
            context "when no task_branch params" do
              it "should be unauthorized" do
                post :create, params: { task: valid_attributes },
                              as: :turbo_stream
                expect_to_be_forbidden(response)
              end
            end

            context "when task_branch params" do
              it "should be unauthorized" do
                post :create, params: { task: valid_attributes,
                                        task_branch: valid_branch_attributes },
                              as: :turbo_stream
                expect_to_be_forbidden(response)
              end
            end
          end
        end

        context "for invisible project but a visible project" do
          let(:project) { Fabricate(:invisible_project) }

          before do
            Fabricate(:project)
          end

          context "when html request" do
            it "should be unauthorized" do
              post :create, params: { task: valid_attributes }
              expect_to_be_unauthorized(response)
            end
          end

          context "when turbo_stream request" do
            context "when no task_branch params" do
              it "should be unauthorized" do
                post :create, params: { task: valid_attributes },
                              as: :turbo_stream
                expect_to_be_forbidden(response)
              end
            end

            context "when task_branch params" do
              it "should be unauthorized" do
                post :create, params: { task: valid_attributes,
                                        task_branch: valid_branch_attributes },
                              as: :turbo_stream
                expect_to_be_forbidden(response)
              end
            end
          end
        end
      end
    end
  end

  describe "GET #edit" do
    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        context "when visible projects" do
          before do
            Fabricate(:project)
          end

          it "returns a success response" do
            task = Fabricate(:task, project: old_project)
            get :edit, params: { task_id: task.to_param }
            expect(response).to be_successful
          end
        end

        context "when invisible projects" do
          let(:old_project) { Fabricate(:invisible_project) }

          before do
            Fabricate(:invisible_project)
          end

          it "returns a success response" do
            task = Fabricate(:task, project: old_project)
            get :edit, params: { task_id: task.to_param }
            expect(response).to be_successful
          end
        end

        context "when internal projects" do
          let(:old_project) { Fabricate(:internal_project) }

          before do
            Fabricate(:internal_project)
          end

          it "returns a success response" do
            task = Fabricate(:task, project: old_project)
            get :edit, params: { task_id: task.to_param }
            expect(response).to be_successful
          end
        end

        context "when only one project" do
          let(:project) { Fabricate(:project) }

          it "redirects to root" do
            task = Fabricate(:task, project: project)
            get :edit, params: { task_id: task.to_param }
            expect(response).to redirect_to(:root)
          end
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before do
          Fabricate(:project)
          sign_in(current_user)
        end

        it "should be unauthorized" do
          task = Fabricate(:task, project: old_project)
          get :edit, params: { task_id: task.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "PUT #update" do
    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        before { sign_in(Fabricate("user_#{employee_type}")) }

        context "with valid params" do
          context "for visible projects" do
            let(:old_project) { Fabricate(:project) }
            let(:task) { Fabricate(:task, project: old_project) }

            it "updates the requested task" do
              expect do
                put :update, params: { task_id: task.to_param,
                                       task: valid_attributes }
                task.reload
              end.to change(task, :project_id).to(project.id)
            end

            it "redirects to the task" do
              task = Fabricate(:task)
              put :update, params: { task_id: task.to_param,
                                     task: valid_attributes }
              expect(response).to redirect_to(task)
            end
          end

          context "for invisible projects" do
            let(:old_project) { Fabricate(:invisible_project) }
            let(:project) { Fabricate(:invisible_project) }
            let(:task) { Fabricate(:task, project: old_project) }

            it "updates the requested task" do
              expect do
                put :update, params: { task_id: task.to_param,
                                       task: valid_attributes }
                task.reload
              end.to change(task, :project_id).to(project.id)
            end

            it "redirects to the task" do
              task = Fabricate(:task)
              put :update, params: { task_id: task.to_param,
                                     task: valid_attributes }
              expect(response).to redirect_to(task)
            end
          end

          context "for invisible project moving from visible" do
            let(:old_project) { Fabricate(:project) }
            let(:project) { Fabricate(:invisible_project) }
            let(:task) { Fabricate(:task, project: old_project) }

            it "updates the requested task" do
              expect do
                put :update, params: { task_id: task.to_param,
                                       task: valid_attributes }
                task.reload
              end.to change(task, :project_id).to(project.id)
            end

            it "redirects to the task" do
              task = Fabricate(:task)
              put :update, params: { task_id: task.to_param,
                                     task: valid_attributes }
              expect(response).to redirect_to(task)
            end
          end
        end

        context "with invalid params" do
          it "doesn't update the requested task" do
            task = Fabricate(:task)
            expect do
              put :update, params: { task_id: task.to_param,
                                     task: invalid_attributes }
              task.reload
            end.not_to change(task, :project_id)
          end

          it "redirects to edit" do
            task = Fabricate(:task)
            put :update, params: { task_id: task.to_param,
                                   task: invalid_attributes }
            expect(response).to be_successful
          end
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        before { sign_in(Fabricate("user_#{employee_type}")) }

        it "redirects to unauthorized" do
          task = Fabricate(:task)
          put :update, params: { task_id: task.to_param,
                                 task: valid_attributes }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end
end
