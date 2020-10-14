# frozen_string_literal: true

require "rails_helper"

RSpec.describe TaskConnectionsController, type: :controller do
  let(:project) { Fabricate(:project) }
  let(:source_task) { Fabricate(:task, project: project) }
  let(:target_task) { Fabricate(:task, project: project) }
  let(:valid_attributes) { { target_id: target_task.to_param } }
  let(:invalid_attributes) { { target_id: "" } }
  let(:path) do
    category_project_task_path(source_task.category, source_task.project,
                               source_task)
  end

  before { login(Fabricate(:user_admin)) }

  describe "GET #new" do
    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        it "returns a success response" do
          get :new, params: { source_id: source_task.to_param }
          expect(response).to be_successful
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        it "should be unauthorized" do
          get :new, params: { source_id: source_task.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "POST #create" do
    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        context "with valid params" do
          it "creates a new TaskConnection for the source" do
            expect do
              post :create, params: { source_id: source_task.to_param,
                                      task_connection: valid_attributes }
              source_task.reload
            end.to change(source_task, :source_task_connection).from(nil)
          end

          it "creates a new TaskConnection for the target" do
            expect do
              post :create, params: { source_id: source_task.to_param,
                                      task_connection: valid_attributes }
              target_task.reload
            end.to change(target_task.target_task_connections, :count).by(1)
          end

          it "closes the source task" do
            expect do
              post :create, params: { source_id: source_task.to_param,
                                      task_connection: valid_attributes }
              source_task.reload
            end.to change(source_task, :closed).to(true)
          end

          it "redirects to the created task_connection" do
            post :create, params: { source_id: source_task.to_param,
                                    task_connection: valid_attributes }
            expect(response).to redirect_to(path)
          end
        end

        context "with invalid params" do
          it "doesn't create a new TaskConnection" do
            expect do
              post :create, params: { source_id: source_task.to_param,
                                      task_connection: invalid_attributes }
              source_task.reload
            end.not_to change(TaskConnection, :count)
          end

          it "returns a success response ('new' template)" do
            post :create, params: { source_id: source_task.to_param,
                                    task_connection: invalid_attributes }
            expect(response).to be_successful
          end
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        it "doesn't create a new TaskConnection" do
          expect do
            post :create, params: { source_id: source_task.to_param,
                                    task_connection: valid_attributes }
          end.not_to change(TaskConnection, :count)
        end

        it "doesn't close the source task" do
          expect do
            post :create, params: { source_id: source_task.to_param,
                                    task_connection: valid_attributes }
            source_task.reload
          end.not_to change(source_task, :closed).from(false)
        end

        it "should be unauthorized" do
          post :create, params: { source_id: source_task.to_param,
                                  task_connection: valid_attributes }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "DELETE #destroy" do
    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        it "destroys the requested task_connection" do
          task_connection = Fabricate(:task_connection, source: source_task)
          expect do
            delete :destroy, params: { id: task_connection.to_param }
          end.to change(TaskConnection, :count).by(-1)
        end

        it "redirects to the task_connections list" do
          task_connection = Fabricate(:task_connection, source: source_task)
          delete :destroy, params: { id: task_connection.to_param }
          expect(response).to redirect_to(path)
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        it "doesn't destroy the requested task_connection" do
          task_connection = Fabricate(:task_connection, source: source_task)
          expect do
            delete :destroy, params: { id: task_connection.to_param }
          end.not_to change(TaskConnection, :count)
        end

        it "should be unauthorized" do
          task_connection = Fabricate(:task_connection, source: source_task)
          delete :destroy, params: { id: task_connection.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end
end
