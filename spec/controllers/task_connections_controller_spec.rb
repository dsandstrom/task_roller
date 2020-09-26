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

  describe "GET #new" do
    it "returns a success response" do
      get :new, params: { source_id: source_task.to_param }
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
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

      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { source_id: source_task.to_param,
                                task_connection: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe "DELETE #destroy" do
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
