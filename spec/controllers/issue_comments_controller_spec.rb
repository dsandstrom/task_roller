# frozen_string_literal: true

require "rails_helper"

RSpec.describe IssueCommentsController, type: :controller do
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:issue) { Fabricate(:issue, project: project) }
  let(:user) { Fabricate(:user_worker) }

  let(:valid_attributes) { { user_id: user.id, body: "Body" } }

  let(:invalid_attributes) { { body: "" } }

  describe "GET #new" do
    it "returns a success response" do
      get :new, params: { category_id: category.to_param,
                          project_id: project.to_param,
                          issue_id: issue.to_param }
      expect(response).to be_success
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      issue_comment = Fabricate(:issue_comment, issue: issue)
      get :edit, params: { category_id: category.to_param,
                           project_id: project.to_param,
                           issue_id: issue.to_param,
                           id: issue_comment.to_param }
      expect(response).to be_success
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new IssueComment" do
        expect do
          post :create, params: { category_id: category.to_param,
                                  project_id: project.to_param,
                                  issue_id: issue.to_param,
                                  issue_comment: valid_attributes }
        end.to change(IssueComment, :count).by(1)
      end

      it "redirects to the created issue_comment" do
        post :create, params: { category_id: category.to_param,
                                project_id: project.to_param,
                                issue_id: issue.to_param,
                                issue_comment: valid_attributes }
        expect(response)
          .to redirect_to(category_project_issue_url(category, project, issue))
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { category_id: category.to_param,
                                project_id: project.to_param,
                                issue_id: issue.to_param,
                                issue_comment: invalid_attributes }
        expect(response).to be_success
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { body: "New body" } }

      it "updates the requested issue_comment" do
        issue_comment = Fabricate(:issue_comment, issue: issue)
        expect do
          put :update, params: { category_id: category.to_param,
                                 project_id: project.to_param,
                                 issue_id: issue.to_param,
                                 id: issue_comment.to_param,
                                 issue_comment: new_attributes }
          issue_comment.reload
        end.to change(issue_comment, :body).to("New body")
      end

      it "redirects to the issue_comment" do
        issue_comment = Fabricate(:issue_comment, issue: issue)
        put :update, params: { category_id: category.to_param,
                               project_id: project.to_param,
                               issue_id: issue.to_param,
                               id: issue_comment.to_param,
                               issue_comment: new_attributes }
        expect(response)
          .to redirect_to(category_project_issue_url(category, project, issue))
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'edit' template)" do
        issue_comment = Fabricate(:issue_comment, issue: issue)
        put :update, params: { category_id: category.to_param,
                               project_id: project.to_param,
                               issue_id: issue.to_param,
                               id: issue_comment.to_param,
                               issue_comment: invalid_attributes }
        expect(response).to be_success
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested issue_comment" do
      issue_comment = Fabricate(:issue_comment, issue: issue)
      expect do
        delete :destroy, params: { category_id: category.to_param,
                                   project_id: project.to_param,
                                   issue_id: issue.to_param,
                                   id: issue_comment.to_param }
      end.to change(IssueComment, :count).by(-1)
    end

    it "redirects to the issue_comments list" do
      issue_comment = Fabricate(:issue_comment, issue: issue)
      delete :destroy, params: { category_id: category.to_param,
                                 project_id: project.to_param,
                                 issue_id: issue.to_param,
                                 id: issue_comment.to_param }
      expect(response)
        .to redirect_to(category_project_issue_url(category, project, issue))
    end
  end
end
