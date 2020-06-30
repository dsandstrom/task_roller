# frozen_string_literal: true

require "rails_helper"

RSpec.describe IssuesController, type: :controller do
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:issue_type) { Fabricate(:issue_type) }
  let(:user) { Fabricate(:user_reporter) }

  let(:valid_attributes) do
    { issue_type_id: issue_type.id, user_id: user.id, summary: "Summary",
      description: "Description" }
  end

  let(:invalid_attributes) { { summary: "" } }

  describe "GET #index" do
    let(:category) { Fabricate(:category) }
    let(:project) { Fabricate(:project, category: category) }

    context "when only category" do
      it "returns a success response" do
        _issue = Fabricate(:issue, project: project)
        get :index, params: { category_id: category.to_param }
        expect(response).to be_successful
      end
    end

    context "when category and project" do
      it "returns a success response" do
        _issue = Fabricate(:issue, project: project)
        get :index, params: { category_id: category.to_param,
                              project_id: project.to_param }
        expect(response).to be_successful
      end
    end
  end

  describe "GET #show" do
    context "when only category" do
      it "returns a success response" do
        issue = Fabricate(:issue, project: project)
        get :show, params: { category_id: category.to_param,
                             id: issue.to_param }
        expect(response).to be_successful
      end
    end

    context "when category and project" do
      it "returns a success response" do
        issue = Fabricate(:issue, project: project)
        get :show, params: { category_id: category.to_param,
                             project_id: project.to_param,
                             id: issue.to_param }
        expect(response).to be_successful
      end
    end
  end

  describe "GET #new" do
    context "when an IssueType and a User" do
      before do
        Fabricate(:issue_type)
        Fabricate(:user_reporter)
      end

      it "returns a success response" do
        get :new, params: { category_id: category.to_param,
                            project_id: project.to_param }
        expect(response).to be_successful
      end
    end

    context "when no IssueTypes" do
      before { Fabricate(:user_reporter) }

      it "redirects to project" do
        get :new, params: { category_id: category.to_param,
                            project_id: project.to_param }
        expect(response).to redirect_to(category_project_url(category, project))
      end
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      issue = Fabricate(:issue, project: project)
      get :edit, params: { category_id: category.to_param,
                           project_id: project.to_param,
                           id: issue.to_param }
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Issue" do
        expect do
          post :create, params: { category_id: category.to_param,
                                  project_id: project.to_param,
                                  issue: valid_attributes }
        end.to change(Issue, :count).by(1)
      end

      it "redirects to the created issue" do
        post :create, params: { category_id: category.to_param,
                                project_id: project.to_param,
                                issue: valid_attributes }
        url = category_project_issue_path(category, project, Issue.last)
        expect(response).to redirect_to(url)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { category_id: category.to_param,
                                project_id: project.to_param,
                                issue: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { summary: "New Summary" } }

      it "updates the requested issue" do
        issue = Fabricate(:issue, project: project)

        expect do
          put :update, params: { category_id: category.to_param,
                                 project_id: project.to_param,
                                 id: issue.to_param,
                                 issue: new_attributes }
          issue.reload
        end.to change(issue, :summary).to("New Summary")
      end

      it "redirects to the issue" do
        issue = Fabricate(:issue, project: project)
        put :update, params: { category_id: category.to_param,
                               project_id: project.to_param,
                               id: issue.to_param,
                               issue: new_attributes }
        expect(response)
          .to redirect_to(category_project_issue_url(category, project, issue))
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'edit' template)" do
        issue = Fabricate(:issue, project: project)
        put :update, params: { category_id: category.to_param,
                               project_id: project.to_param,
                               id: issue.to_param,
                               issue: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested issue" do
      issue = Fabricate(:issue, project: project)
      expect do
        delete :destroy, params: { category_id: category.to_param,
                                   project_id: project.to_param,
                                   id: issue.to_param }
      end.to change(Issue, :count).by(-1)
    end

    it "redirects to the issues list" do
      issue = Fabricate(:issue, project: project)
      delete :destroy, params: { category_id: category.to_param,
                                 project_id: project.to_param,
                                 id: issue.to_param }
      expect(response).to redirect_to(category_project_url(category, project))
    end
  end

  describe "PUT #open" do
    context "with valid params" do
      let(:new_attributes) {}

      it "updates the requested issue" do
        issue = Fabricate(:closed_issue, project: project)

        expect do
          put :open, params: { category_id: category.to_param,
                               project_id: project.to_param,
                               id: issue.to_param }
          issue.reload
        end.to change(issue, :closed).to(false)
      end

      it "redirects to the issue" do
        issue = Fabricate(:closed_issue, project: project)
        put :open, params: { category_id: category.to_param,
                             project_id: project.to_param,
                             id: issue.to_param }
        expect(response)
          .to redirect_to(category_project_issue_url(category, project, issue))
      end
    end

    # context "with invalid params" do
    #   it "returns a success response (i.e. to display the 'edit' template)" do
    #     issue = Fabricate(:closed_issue, project: project)
    #     put :open, params: { category_id: category.to_param,
    #                          project_id: project.to_param,
    #                          id: issue.to_param }
    #     expect(response).to be_successful
    #   end
    # end
  end

  describe "PUT #close" do
    context "with valid params" do
      let(:new_attributes) {}

      it "updates the requested issue" do
        issue = Fabricate(:open_issue, project: project)

        expect do
          put :close, params: { category_id: category.to_param,
                                project_id: project.to_param,
                                id: issue.to_param }
          issue.reload
        end.to change(issue, :closed).to(true)
      end

      it "redirects to the issue" do
        issue = Fabricate(:open_issue, project: project)
        put :close, params: { category_id: category.to_param,
                              project_id: project.to_param,
                              id: issue.to_param }
        expect(response)
          .to redirect_to(category_project_issue_url(category, project, issue))
      end
    end

    # context "with invalid params" do
    #   it "returns a success response (i.e. to display the 'edit' template)" do
    #     issue = Fabricate(:open_issue, project: project)
    #     put :close, params: { category_id: category.to_param,
    #                          project_id: project.to_param,
    #                          id: issue.to_param }
    #     expect(response).to be_successful
    #   end
    # end
  end

  describe "PUT #open" do
    context "with valid params" do
      let(:new_attributes) {}

      it "updates the requested issue" do
        issue = Fabricate(:closed_issue, project: project)

        expect do
          put :open, params: { category_id: category.to_param,
                               project_id: project.to_param,
                               id: issue.to_param }
          issue.reload
        end.to change(issue, :closed).to(false)
      end

      it "redirects to the issue" do
        issue = Fabricate(:closed_issue, project: project)
        put :open, params: { category_id: category.to_param,
                             project_id: project.to_param,
                             id: issue.to_param }
        expect(response)
          .to redirect_to(category_project_issue_url(category, project, issue))
      end
    end

    context "with invalid params" do
      let(:issue) { Fabricate(:closed_issue, project: project) }

      before { issue.user.destroy }

      it "doesn't update the requested issue" do
        expect do
          put :open, params: { category_id: category.to_param,
                               project_id: project.to_param,
                               id: issue.to_param }
          issue.reload
        end.not_to change(issue, :closed)
      end

      it "returns a success response (i.e. to display the 'edit' template)" do
        put :open, params: { category_id: category.to_param,
                             project_id: project.to_param,
                             id: issue.to_param }
        expect(response).to be_successful
      end
    end
  end

  describe "PUT #close" do
    context "with valid params" do
      let(:new_attributes) {}

      it "updates the requested issue" do
        issue = Fabricate(:open_issue, project: project)

        expect do
          put :close, params: { category_id: category.to_param,
                                project_id: project.to_param,
                                id: issue.to_param }
          issue.reload
        end.to change(issue, :closed).to(true)
      end

      it "redirects to the issue" do
        issue = Fabricate(:open_issue, project: project)
        put :close, params: { category_id: category.to_param,
                              project_id: project.to_param,
                              id: issue.to_param }
        expect(response)
          .to redirect_to(category_project_issue_url(category, project, issue))
      end
    end

    context "with invalid params" do
      let(:issue) { Fabricate(:closed_issue, project: project) }

      before { issue.user.destroy }

      it "returns a success response (i.e. to display the 'edit' template)" do
        put :close, params: { category_id: category.to_param,
                              project_id: project.to_param,
                              id: issue.to_param }
        expect(response).to be_successful
      end

      it "doesn't update the requested issue" do
        expect do
          put :close, params: { category_id: category.to_param,
                                project_id: project.to_param,
                                id: issue.to_param }
          issue.reload
        end.not_to change(issue, :closed)
      end
    end
  end
end
