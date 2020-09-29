# frozen_string_literal: true

require "rails_helper"

RSpec.describe ResolutionsController, type: :controller do
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:issue) { Fabricate(:issue, project: project) }
  let(:user_reporter) { Fabricate(:user_reporter) }

  let(:valid_attributes) do
    { user_id: user_reporter.id }
  end

  let(:invalid_attributes) do
    { user_id: "" }
  end

  before { login(Fabricate(:user_admin)) }

  describe "GET #index" do
    it "returns a success response" do
      _resolution = Fabricate(:resolution, issue: issue)
      get :index, params: { issue_id: issue.to_param }
      expect(response).to be_successful
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new, params: { issue_id: issue.to_param }
      expect(response).to be_successful
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      resolution = Fabricate(:resolution, issue: issue)
      get :edit, params: { issue_id: issue.to_param,
                           id: resolution.to_param }
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Resolution" do
        expect do
          post :create, params: { issue_id: issue.to_param,
                                  resolution: valid_attributes }
        end.to change(Resolution, :count).by(1)
      end

      it "redirects to the issue" do
        post :create, params: { issue_id: issue.to_param,
                                resolution: valid_attributes }
        expect(response)
          .to redirect_to(category_project_issue_path(category, project, issue))
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { issue_id: issue.to_param,
                                resolution: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe "PUT #approve" do
    context "with valid params" do
      it "updates the requested resolution" do
        expect do
          post :approve, params: { issue_id: issue.to_param,
                                   resolution: valid_attributes }
        end.to change(issue.resolutions.approved, :count).by(1)
      end

      it "redirects to the resolution" do
        post :approve, params: { issue_id: issue.to_param,
                                 resolution: valid_attributes }
        expect(response)
          .to redirect_to(category_project_issue_path(category, project, issue))
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'edit' template)" do
        post :approve, params: { issue_id: issue.to_param,
                                 resolution: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe "PUT #disapprove" do
    context "with valid params" do
      it "updates the requested resolution" do
        expect do
          post :disapprove, params: { issue_id: issue.to_param,
                                      resolution: valid_attributes }
        end.to change(issue.resolutions.disapproved, :count).by(1)
      end

      it "redirects to the resolution" do
        post :disapprove, params: { issue_id: issue.to_param,
                                    resolution: valid_attributes }
        expect(response)
          .to redirect_to(category_project_issue_path(category, project, issue))
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'edit' template)" do
        post :disapprove, params: { issue_id: issue.to_param,
                                    resolution: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested resolution" do
      resolution = Fabricate(:resolution, issue: issue)
      expect do
        delete :destroy, params: { issue_id: issue.to_param,
                                   id: resolution.to_param }
      end.to change(Resolution, :count).by(-1)
    end

    it "redirects to the resolutions list" do
      resolution = Fabricate(:resolution, issue: issue)
      delete :destroy, params: { issue_id: issue.to_param,
                                 id: resolution.to_param }
      expect(response)
        .to redirect_to(category_project_issue_path(category, project, issue))
    end
  end
end
