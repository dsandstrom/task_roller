# frozen_string_literal: true

require "rails_helper"

RSpec.describe IssueConnectionsController, type: :controller do
  let(:source_issue) { Fabricate(:issue) }
  let(:target_issue) { Fabricate(:issue) }
  let(:path) do
    category_project_issue_path(source_issue.category,
                                source_issue.project, source_issue)
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new, params: { source_id: source_issue.to_param }
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new IssueConnection to the source" do
        expect do
          post :create, params: { source_id: source_issue.to_param,
                                  target_id: target_issue.to_param }
          source_issue.reload
        end.to change(source_issue.source_issue_connections, :count).by(1)
      end

      it "creates a new IssueConnection to the target" do
        expect do
          post :create, params: { source_id: source_issue.to_param,
                                  target_id: target_issue.to_param }
          source_issue.reload
        end.to change(target_issue.target_issue_connections, :count).by(1)
      end

      it "redirects to the created issue_connection" do
        post :create, params: { source_id: source_issue.to_param,
                                target_id: target_issue.to_param }
        expect(response).to redirect_to(path)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { source_id: source_issue.to_param,
                                target_id: "" }
        expect(response).to be_successful
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested issue_connection" do
      issue_connection = Fabricate(:issue_connection, source: source_issue)
      expect do
        delete :destroy, params: { id: issue_connection.to_param }
      end.to change(IssueConnection, :count).by(-1)
    end

    it "redirects to the issue_connections list" do
      issue_connection = Fabricate(:issue_connection, source: source_issue)
      delete :destroy, params: { id: issue_connection.to_param }
      expect(response).to redirect_to(path)
    end
  end
end
