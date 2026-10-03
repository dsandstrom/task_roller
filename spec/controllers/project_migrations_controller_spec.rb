require "rails_helper"

RSpec.describe ProjectMigrationsController, type: :controller do
  before do
    Fabricate(:issue_type)
    Fabricate(:task_type)
  end

  describe "GET #new" do
    let(:project) { Fabricate(:project) }

    %w[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when another project" do
          before do
            Fabricate(:project)
          end

          it "returns a success response" do
            get :new, params: { project_id: project.id }

            expect(response).to be_successful
          end
        end

        context "when no other projects" do
          it "redirects to root" do
            get :new, params: { project_id: project.id }

            expect(response).to redirect_to(:root)
          end
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        it "should be unauthorized" do
          get :new, params: { project_id: project.id }

          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "POST #create" do
    let!(:project) { Fabricate(:project) }
    let!(:new_project) { Fabricate(:project) }
    let!(:task) { Fabricate(:task, project: project) }
    let!(:issue) { Fabricate(:issue, project: project) }

    let(:valid_params) { { migration_id: new_project.to_param } }
    let(:invalid_params) { { migration_id: "" } }

    %w[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when current project has a task and issue" do
          context "when valid params" do
            it "updates the task's project" do
              expect do
                post :create, params: { project_id: project.id,
                                        project: valid_params }
                task.reload
              end.to change(task, :project_id).to(new_project.id)
            end

            it "updates the issue's project" do
              expect do
                post :create, params: { project_id: project.id,
                                        project: valid_params }
                issue.reload
              end.to change(issue, :project_id).to(new_project.id)
            end

            it "redirects to old category" do
              post :create, params: { project_id: project.id,
                                      project: valid_params }

              expect(response).to redirect_to(category_path(project.category))
            end
          end

          context "when invalid params" do
            it "doesn't update the task" do
              expect do
                post :create, params: { project_id: project.id,
                                        project: invalid_params }
                task.reload
              end.not_to change(task, :project_id)
            end

            it "doesn't update the issue" do
              expect do
                post :create, params: { project_id: project.id,
                                        project: invalid_params }
                issue.reload
              end.not_to change(issue, :project_id)
            end

            it "returns a success response" do
              post :create, params: { project_id: project.id,
                                      project: invalid_params }

              expect(response).to be_successful
            end
          end
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        it "doesn't update the task" do
          expect do
            post :create, params: { project_id: project.id,
                                    project: valid_params }
            task.reload
          end.not_to change(task, :project_id)
        end

        it "doesn't update the issue" do
          expect do
            post :create, params: { project_id: project.id,
                                    project: valid_params }
            issue.reload
          end.not_to change(issue, :project_id)
        end

        it "should be unauthorized" do
          post :create, params: { project_id: project.id,
                                  project: valid_params }

          expect_to_be_unauthorized(response)
        end
      end
    end
  end
end
