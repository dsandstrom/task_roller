# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProjectsController, type: :controller do
  let!(:category) { Fabricate(:category) }
  let(:invalid_attributes) { { name: "" } }

  describe "GET #index" do
    it "returns a success response" do
      _project = Fabricate(:project, category: category)
      get :index
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      project = Fabricate(:project, category: category)
      get :show, params: { id: project.to_param,
                           category_id: category.to_param }
      expect(response).to be_successful
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new, params: { category_id: category.to_param }
      expect(response).to be_successful
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      project = Fabricate(:project, category: category)
      get :edit, params: { id: project.to_param,
                           category_id: category.to_param }
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    let(:valid_attributes) { { name: "Project Name" } }

    context "with valid params" do
      it "creates a new Project" do
        expect do
          post :create, params: { category_id: category.to_param,
                                  project: valid_attributes }
        end.to change(Project, :count).by(1)
      end

      it "redirects to the created project" do
        post :create, params: { category_id: category.to_param,
                                project: valid_attributes }
        expect(response)
          .to redirect_to(category_project_path(category, Project.last))
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { category_id: category.to_param,
                                project: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { name: "New Name" } }

      it "updates the requested project" do
        project = Fabricate(:project, category: category)
        expect do
          put :update, params: { id: project.to_param,
                                 category_id: category.to_param,
                                 project: new_attributes }
          project.reload
        end.to change(project, :name).to("New Name")
      end

      it "redirects to the project" do
        project = Fabricate(:project, category: category)
        put :update, params: { id: project.to_param,
                               category_id: category.to_param,
                               project: new_attributes }
        expect(response)
          .to redirect_to(category_project_path(category, project))
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'edit' template)" do
        project = Fabricate(:project, category: category)
        put :update, params: { id: project.to_param,
                               category_id: category.to_param,
                               project: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested project" do
      project = Fabricate(:project, category: category)
      expect do
        delete :destroy, params: { id: project.to_param,
                                   category_id: category.to_param }
      end.to change(Project, :count).by(-1)
    end

    it "redirects to the categories list" do
      project = Fabricate(:project, category: category)
      delete :destroy, params: { id: project.to_param,
                                 category_id: category.to_param }
      expect(response).to redirect_to(category)
    end
  end
end
