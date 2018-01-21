# frozen_string_literal: true

require "rails_helper"

RSpec.describe UsersController, type: :controller do
  let(:invalid_attributes) { { name: "" } }

  describe "GET #index" do
    context "when no users" do
      it "returns a success response" do
        get :index
        expect(response).to be_success
      end
    end

    context "when users" do
      it "returns a success response" do
        Fabricate(:user_reporter)
        Fabricate(:user_reviewer)
        Fabricate(:user_worker)
        get :index
        expect(response).to be_success
      end
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      user = Fabricate(:user)
      get :show, params: { id: user.to_param }
      expect(response).to be_success
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new
      expect(response).to be_success
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      user = Fabricate(:user)
      get :edit, params: { id: user.to_param }
      expect(response).to be_success
    end
  end

  describe "POST #create" do
    let(:valid_attributes) do
      { name: "User Name", email: "user-email@example.com",
        employee_type: "Worker" }
    end

    context "with valid params" do
      it "creates a new User" do
        expect do
          post :create, params: { user: valid_attributes }
        end.to change(User, :count).by(1)
      end

      it "redirects to the created user" do
        post :create, params: { user: valid_attributes }
        expect(response).to redirect_to(User.last)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { user: invalid_attributes }
        expect(response).to be_success
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:valid_attributes) { { name: "New Name" } }

      it "updates the requested user" do
        user = Fabricate(:user)
        expect do
          put :update, params: { id: user.to_param, user: valid_attributes }
          user.reload
        end.to change(user, :name).to("New Name")
      end

      it "redirects to the user" do
        user = Fabricate(:user)
        put :update, params: { id: user.to_param, user: valid_attributes }
        expect(response).to redirect_to(user)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'edit' template)" do
        user = Fabricate(:user)
        put :update, params: { id: user.to_param, user: invalid_attributes }
        expect(response).to be_success
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested user" do
      user = Fabricate(:user)
      expect do
        delete :destroy, params: { id: user.to_param }
      end.to change(User, :count).by(-1)
    end

    it "redirects to the users list" do
      user = Fabricate(:user)
      delete :destroy, params: { id: user.to_param }
      expect(response).to redirect_to(users_url)
    end
  end
end
