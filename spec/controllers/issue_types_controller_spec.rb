# frozen_string_literal: true

require "rails_helper"

RSpec.describe IssueTypesController, type: :controller do
  let(:valid_attributes) { { name: "Bug", icon: "bug", color: "red" } }
  let(:invalid_attributes) { { name: "" } }

  describe "GET #new" do
    it "returns a success response" do
      get :new, params: {}
      expect(response).to be_successful
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      issue_type = Fabricate(:issue_type)
      get :edit, params: { id: issue_type.to_param }
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new IssueType" do
        expect do
          post :create, params: { issue_type: valid_attributes }
        end.to change(IssueType, :count).by(1)
      end

      it "redirects to the issue_type list" do
        post :create, params: { issue_type: valid_attributes }
        expect(response).to redirect_to(roller_types_url)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { issue_type: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { name: "New Name" } }

      it "updates the requested issue_type" do
        issue_type = Fabricate(:issue_type)
        expect do
          put :update, params: { id: issue_type.to_param,
                                 issue_type: new_attributes }
          issue_type.reload
        end.to change(issue_type, :name).to("New Name")
      end

      it "redirects to the issue_type list" do
        issue_type = Fabricate(:issue_type)
        put :update, params: { id: issue_type.to_param,
                               issue_type: valid_attributes }
        expect(response).to redirect_to(roller_types_url)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'edit' template)" do
        issue_type = Fabricate(:issue_type)
        put :update, params: { id: issue_type.to_param,
                               issue_type: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested issue_type" do
      issue_type = Fabricate(:issue_type)
      expect do
        delete :destroy, params: { id: issue_type.to_param }
      end.to change(IssueType, :count).by(-1)
    end

    it "redirects to the issue_types list" do
      issue_type = Fabricate(:issue_type)
      delete :destroy, params: { id: issue_type.to_param }
      expect(response).to redirect_to(roller_types_url)
    end
  end
end
