# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProjectsController, type: :controller do
  let(:category) { Fabricate(:category) }
  let(:invalid_attributes) { { name: "" } }

  before { login(Fabricate(:user_admin)) }

  describe "GET #index" do
    context "for an admin" do
      let(:admin) { Fabricate(:user_admin) }

      before { login(admin) }

      it "returns a success response" do
        _project = Fabricate(:project)
        get :index
        expect(response).to be_successful
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        before { login(Fabricate("user_#{employee_type}")) }

        it "should be unauthorized" do
          _project = Fabricate(:project)
          get :index
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "GET #show" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        before { login(Fabricate("user_#{employee_type.downcase}")) }

        it "returns a success response" do
          project = Fabricate(:project, category: category)
          get :show, params: { id: project.to_param,
                               category_id: category.to_param }
          expect(response).to be_successful
        end
      end
    end
  end

  describe "GET #new" do
    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        before { login(Fabricate("user_#{employee_type}")) }

        it "returns a success response" do
          get :new, params: { category_id: category.to_param }
          expect(response).to be_successful
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        before { login(Fabricate("user_#{employee_type}")) }

        it "should be unauthorized" do
          get :new, params: { category_id: category.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "GET #edit" do
    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        before { login(Fabricate("user_#{employee_type}")) }

        it "returns a success response" do
          project = Fabricate(:project, category: category)
          get :edit, params: { id: project.to_param,
                               category_id: category.to_param }
          expect(response).to be_successful
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        before { login(Fabricate("user_#{employee_type}")) }

        it "should be unauthorized" do
          project = Fabricate(:project, category: category)
          get :edit, params: { id: project.to_param,
                               category_id: category.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "POST #create" do
    let(:valid_attributes) { { name: "Project Name" } }

    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        before { login(Fabricate("user_#{employee_type}")) }

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
            expect(response).to redirect_to(project_path(Project.last))
          end
        end

        context "with invalid params" do
          it "returns a success response ('new' template)" do
            post :create, params: { category_id: category.to_param,
                                    project: invalid_attributes }
            expect(response).to be_successful
          end
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        before { login(Fabricate("user_#{employee_type}")) }

        it "should be unauthorized" do
          post :create, params: { category_id: category.to_param,
                                  project: valid_attributes }
          expect_to_be_unauthorized(response)
        end

        it "shouldn't create a Project" do
          expect do
            post :create, params: { category_id: category.to_param,
                                    project: valid_attributes }
          end.not_to change(Project, :count)
        end
      end
    end
  end

  describe "PUT #update" do
    let(:new_attributes) { { name: "New Name" } }

    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        before { login(Fabricate("user_#{employee_type}")) }

        context "with valid params" do
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
            expect(response).to redirect_to(project_path(project))
          end
        end

        context "with invalid params" do
          it "returns a success response ('edit' template)" do
            project = Fabricate(:project, category: category)
            put :update, params: { id: project.to_param,
                                   category_id: category.to_param,
                                   project: invalid_attributes }
            expect(response).to be_successful
          end
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        before { login(Fabricate("user_#{employee_type}")) }

        it "should be unauthorized" do
          project = Fabricate(:project, category: category)
          put :update, params: { id: project.to_param,
                                 category_id: category.to_param,
                                 project: new_attributes }
          expect_to_be_unauthorized(response)
        end

        it "shouldn't update the project" do
          project = Fabricate(:project, category: category)
          expect do
            put :update, params: { id: project.to_param,
                                   category_id: category.to_param,
                                   project: new_attributes }
            project.reload
          end.not_to change(project, :name)
        end
      end
    end
  end

  describe "DELETE #destroy" do
    context "for an admin" do
      let(:admin) { Fabricate(:user_admin) }

      before { login(admin) }

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

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        before { login(Fabricate("user_#{employee_type}")) }

        it "doesn't destroy the requested category" do
          project = Fabricate(:project, category: category)
          expect do
            delete :destroy, params: { id: project.to_param,
                                       category_id: category.to_param }
          end.not_to change(Project, :count)
        end

        it "should be unauthorized" do
          project = Fabricate(:project, category: category)
          delete :destroy, params: { id: project.to_param,
                                     category_id: category.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end
end
