# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProgressionsController, type: :controller do
  let(:task) { Fabricate(:task) }
  let(:worker) { Fabricate(:user_worker) }

  let(:valid_attributes) do
    { user_id: worker.id.to_s }
  end

  let(:invalid_attributes) do
    { user_id: "" }
  end

  describe "GET #index" do
    it "returns a success response" do
      _progression = Fabricate(:progression, task: task)
      get :index, params: { task_id: task.to_param }
      expect(response).to be_successful
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new, params: { task_id: task.to_param }
      expect(response).to be_successful
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      progression = Fabricate(:progression, task: task)
      get :edit, params: { task_id: task.to_param,
                           id: progression.to_param }
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Progression" do
        expect do
          post :create, params: { task_id: task.to_param,
                                  progression: valid_attributes }
        end.to change(Progression, :count).by(1)
      end

      it "redirects to the created progression" do
        post :create, params: { task_id: task.to_param,
                                progression: valid_attributes }
        expect(response).to redirect_to(task_progressions_path(task))
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { task_id: task.to_param,
                                progression: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe "PUT #update" do
    let(:new_user) { Fabricate(:user_worker) }

    context "with valid params" do
      let(:new_attributes) do
        { user_id: new_user.id.to_s }
      end

      it "updates the requested progression" do
        progression = Fabricate(:progression, task: task)
        expect do
          put :update, params: { task_id: task.to_param,
                                 id: progression.to_param,
                                 progression: new_attributes }
          progression.reload
        end.to change(progression, :user_id).to(new_user.id)
      end

      it "redirects to the progression" do
        progression = Fabricate(:progression, task: task)
        put :update, params: { task_id: task.to_param,
                               id: progression.to_param,
                               progression: valid_attributes }
        expect(response).to redirect_to(task_progressions_path(task))
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'edit' template)" do
        progression = Fabricate(:progression, task: task)
        put :update, params: { task_id: task.to_param,
                               id: progression.to_param,
                               progression: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested progression" do
      progression = Fabricate(:progression, task: task)
      expect do
        delete :destroy, params: { task_id: task.to_param,
                                   id: progression.to_param }
      end.to change(Progression, :count).by(-1)
    end

    it "redirects to the progressions list" do
      progression = Fabricate(:progression, task: task)
      delete :destroy, params: { task_id: task.to_param,
                                 id: progression.to_param }
      expect(response).to redirect_to(task_progressions_path(task))
    end
  end
end
