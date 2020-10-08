# frozen_string_literal: true

require "rails_helper"

RSpec.describe CategoriesController, type: :controller do
  let(:invalid_attributes) { { name: "" } }

  before { login(Fabricate(:user_admin)) }

  describe "GET #index" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        before { login(Fabricate("user_#{employee_type.downcase}")) }

        it "returns a success response" do
          _category = Fabricate(:category)
          get :index
          expect(response).to be_successful
        end
      end
    end
  end

  describe "GET #show" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        before { login(Fabricate("user_#{employee_type.downcase}")) }

        it "returns a success response" do
          category = Fabricate(:category)
          get :show, params: { id: category.to_param }
          expect(response).to be_successful
        end
      end
    end
  end

  describe "GET #new" do
    context "for an admin" do
      before { login(Fabricate(:user_admin)) }

      it "returns a success response" do
        get :new
        expect(response).to be_successful
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        before { login(Fabricate("user_#{employee_type}")) }

        it "should be unauthorized" do
          get :new, params: {}
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "GET #edit" do
    %w[admin reviewer].each do |employee_type|
      before { login(Fabricate("user_#{employee_type}")) }

      it "returns a success response" do
        category = Fabricate(:category)
        get :edit, params: { id: category.to_param }
        expect(response).to be_successful
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        before { login(Fabricate("user_#{employee_type}")) }

        it "should be unauthorized" do
          category = Fabricate(:category)
          get :edit, params: { id: category.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "POST #create" do
    let(:valid_attributes) { { name: "Category Name" } }

    context "for an admin" do
      before { login(Fabricate(:user_admin)) }

      context "with valid params" do
        it "creates a new Category" do
          expect do
            post :create, params: { category: valid_attributes }
          end.to change(Category, :count).by(1)
        end

        it "redirects to the created category" do
          post :create, params: { category: valid_attributes }
          expect(response).to redirect_to(Category.last)
        end
      end

      context "with invalid params" do
        it "returns a success response (i.e. to display the 'new' template)" do
          post :create, params: { category: invalid_attributes }
          expect(response).to be_successful
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        before { login(Fabricate("user_#{employee_type}")) }

        it "should be unauthorized" do
          post :create, params: { category: valid_attributes }
          expect_to_be_unauthorized(response)
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
          it "updates the requested category" do
            category = Fabricate(:category)
            expect do
              put :update, params: { id: category.to_param,
                                     category: new_attributes }
              category.reload
            end.to change(category, :name).to("New Name")
          end

          it "redirects to the category" do
            category = Fabricate(:category)
            put :update, params: { id: category.to_param,
                                   category: new_attributes }
            expect(response).to redirect_to(category)
          end
        end

        context "with invalid params" do
          it "returns a success response ('edit' template)" do
            category = Fabricate(:category)
            put :update, params: { id: category.to_param,
                                   category: invalid_attributes }
            expect(response).to be_successful
          end
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        before { login(Fabricate("user_#{employee_type}")) }

        it "should be unauthorized" do
          post :create, params: { category: new_attributes }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "DELETE #destroy" do
    context "for an admin" do
      let(:admin) { Fabricate(:user_admin) }

      before { login(admin) }

      it "destroys the requested category" do
        category = Fabricate(:category)
        expect do
          delete :destroy, params: { id: category.to_param }
        end.to change(Category, :count).by(-1)
      end

      it "redirects to the categories list" do
        category = Fabricate(:category)
        delete :destroy, params: { id: category.to_param }
        expect(response).to redirect_to(categories_url)
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        before { login(Fabricate("user_#{employee_type}")) }

        it "doesn't destroy the requested category" do
          category = Fabricate(:category)
          expect do
            delete :destroy, params: { id: category.to_param }
          end.not_to change(Category, :count)
        end

        it "should be unauthorized" do
          category = Fabricate(:category)
          delete :destroy, params: { id: category.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end
end
