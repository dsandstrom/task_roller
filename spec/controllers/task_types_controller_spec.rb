# frozen_string_literal: true

require "rails_helper"

RSpec.describe TaskTypesController, type: :controller do
  let(:valid_attributes) { { name: "Bug", icon: "bug", color: "red" } }
  let(:invalid_attributes) { { name: "" } }

  describe "GET #new" do
    it "returns a success response" do
      get :new, params: {}
      expect(response).to be_success
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      task_type = Fabricate(:task_type)
      get :edit, params: { id: task_type.to_param }
      expect(response).to be_success
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new TaskType" do
        expect do
          post :create, params: { task_type: valid_attributes }
        end.to change(TaskType, :count).by(1)
      end

      it "redirects to the task_types list" do
        post :create, params: { task_type: valid_attributes }
        expect(response).to redirect_to(roller_types_url)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { task_type: invalid_attributes }
        expect(response).to be_success
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { name: "New Name" } }

      it "updates the requested task_type" do
        task_type = Fabricate(:task_type)
        expect do
          put :update, params: { id: task_type.to_param,
                                 task_type: new_attributes }
          task_type.reload
        end.to change(task_type, :name).to("New Name")
      end

      it "redirects to the task_types list" do
        task_type = Fabricate(:task_type)
        put :update, params: { id: task_type.to_param,
                               task_type: valid_attributes }
        expect(response).to redirect_to(roller_types_url)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'edit' template)" do
        task_type = Fabricate(:task_type)
        put :update, params: { id: task_type.to_param,
                               task_type: invalid_attributes }
        expect(response).to be_success
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested task_type" do
      task_type = Fabricate(:task_type)
      expect do
        delete :destroy, params: { id: task_type.to_param }
      end.to change(TaskType, :count).by(-1)
    end

    it "redirects to the task_types list" do
      task_type = Fabricate(:task_type)
      delete :destroy, params: { id: task_type.to_param }
      expect(response).to redirect_to(roller_types_url)
    end
  end
end
